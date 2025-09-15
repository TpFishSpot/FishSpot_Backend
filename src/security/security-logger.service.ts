import { Injectable, Logger } from '@nestjs/common';
import { Request } from 'express';

export interface SecurityEvent {
  type: 'SQL_INJECTION' | 'XSS_ATTEMPT' | 'RATE_LIMIT_EXCEEDED' | 'SUSPICIOUS_ACTIVITY' | 'AUTH_FAILURE';
  severity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  ip: string;
  userAgent?: string;
  userId?: string;
  endpoint: string;
  method: string;
  payload?: any;
  message: string;
  timestamp: Date;
}

@Injectable()
export class SecurityLogger {
  private readonly logger = new Logger('Security');
  private readonly securityEvents: SecurityEvent[] = [];
  private readonly MAX_EVENTS = 10000;
  logSecurityEvent(event: Omit<SecurityEvent, 'timestamp'>) {
    const fullEvent: SecurityEvent = {
      ...event,
      timestamp: new Date(),
    };

   
    this.securityEvents.push(fullEvent);

    if (this.securityEvents.length > this.MAX_EVENTS) {
      this.securityEvents.shift();
    }
    const logMessage = `[${event.type}] ${event.message} | IP: ${event.ip} | Endpoint: ${event.endpoint}`;
    
    switch (event.severity) {
      case 'CRITICAL':
        this.logger.error(`🚨 CRITICAL: ${logMessage}`, JSON.stringify(fullEvent));
        break;
      case 'HIGH':
        this.logger.error(`🔴 HIGH: ${logMessage}`);
        break;
      case 'MEDIUM':
        this.logger.warn(`🟡 MEDIUM: ${logMessage}`);
        break;
      case 'LOW':
        this.logger.log(`🟢 LOW: ${logMessage}`);
        break;
    }
    this.checkForRepeatedAttacks(event.ip, event.type);
  }

  logSqlInjectionAttempt(req: Request, suspiciousData: string) {
    this.logSecurityEvent({
      type: 'SQL_INJECTION',
      severity: 'HIGH',
      ip: req.ip || 'unknown',
      userAgent: req.get('User-Agent'),
      endpoint: req.url,
      method: req.method,
      payload: { suspiciousData },
      message: `SQL injection attempt detected: ${suspiciousData.substring(0, 100)}`,
    });
  }

  logXssAttempt(req: Request, suspiciousData: string) {
    this.logSecurityEvent({
      type: 'XSS_ATTEMPT',
      severity: 'MEDIUM',
      ip: req.ip || 'unknown',
      userAgent: req.get('User-Agent'),
      endpoint: req.url,
      method: req.method,
      payload: { suspiciousData },
      message: `XSS attempt detected: ${suspiciousData.substring(0, 100)}`,
    });
  }

  logRateLimitExceeded(req: Request, limit: number) {
    this.logSecurityEvent({
      type: 'RATE_LIMIT_EXCEEDED',
      severity: 'MEDIUM',
      ip: req.ip || 'unknown',
      userAgent: req.get('User-Agent'),
      endpoint: req.url,
      method: req.method,
      message: `Rate limit exceeded: ${limit} requests`,
    });
  }

  logAuthFailure(req: Request, userId?: string, reason?: string) {
    this.logSecurityEvent({
      type: 'AUTH_FAILURE',
      severity: 'MEDIUM',
      ip: req.ip || 'unknown',
      userAgent: req.get('User-Agent'),
      userId,
      endpoint: req.url,
      method: req.method,
      message: `Authentication failure: ${reason || 'Unknown reason'}`,
    });
  }

  private checkForRepeatedAttacks(ip: string, type: SecurityEvent['type']) {
    const recentEvents = this.securityEvents.filter(
      event => 
        event.ip === ip && 
        event.type === type && 
        Date.now() - event.timestamp.getTime() < 300000 
    );

    if (recentEvents.length >= 5) {
      this.logSecurityEvent({
        type: 'SUSPICIOUS_ACTIVITY',
        severity: 'CRITICAL',
        ip,
        endpoint: 'multiple',
        method: 'multiple',
        message: `Repeated ${type} attempts detected from IP ${ip} (${recentEvents.length} times)`,
      });
    }
  }

  getSecuritySummary(hours: number = 24) {
    const cutoff = new Date(Date.now() - hours * 60 * 60 * 1000);
    const recentEvents = this.securityEvents.filter(event => event.timestamp > cutoff);

    const summary = {
      totalEvents: recentEvents.length,
      byType: {} as Record<SecurityEvent['type'], number>,
      bySeverity: {} as Record<SecurityEvent['severity'], number>,
      topIPs: {} as Record<string, number>,
      totalUniqueIPs: new Set(recentEvents.map(e => e.ip)).size,
    };

    recentEvents.forEach(event => {
      summary.byType[event.type] = (summary.byType[event.type] || 0) + 1;
      summary.bySeverity[event.severity] = (summary.bySeverity[event.severity] || 0) + 1;
      summary.topIPs[event.ip] = (summary.topIPs[event.ip] || 0) + 1;
    });

    return summary;
  }
}