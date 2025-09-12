import { Injectable, NestMiddleware, BadRequestException } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { SecurityLogger } from '../security/security-logger.service';

@Injectable()
export class SecurityMiddleware implements NestMiddleware {
  constructor(private readonly securityLogger: SecurityLogger) {}

  private readonly sqlPatterns = [
    /\b(union|select|insert|update|delete|drop|create|alter|exec|execute)\b/gi,
    /(--|\*\/)/gi,
    /=.*['";]/gi,
    /'.*union/gi,
    /\bor\b.*=/gi,
  ];

  private readonly xssPatterns = [
    /<script[\s\S]*?>[\s\S]*?<\/script>/gi,
    /<iframe[\s\S]*?>[\s\S]*?<\/iframe>/gi,
    /javascript:/gi,
    /on\w+\s*=/gi,
  ];

  private readonly otherPatterns = [
    /\.\.\/|\.\.\\|\%2e\%2e\%2f|\%2e\%2e\%5c/gi,
    /(\||&|;|\$|\`)/gi,
  ];

  use(req: Request, res: Response, next: NextFunction) {
    try {
      if (req.query) {
        this.sanitizeAndCheckObject(req.query, 'Query parameter', req);
      }

      if (req.body) {
        this.sanitizeAndCheckObject(req.body, 'Request body', req);
      }

      if (req.params) {
        this.sanitizeAndCheckObject(req.params, 'URL parameter', req);
      }

      this.checkSuspiciousHeaders(req);
      next();
    } catch (error) {
      throw new BadRequestException('Invalid request data');
    }
  }

  private sanitizeAndCheckObject(obj: any, context: string, req: Request): void {
    for (const [key, value] of Object.entries(obj)) {
      if (typeof value === 'string') {
        this.checkForMaliciousContent(value, `${context} '${key}'`, req);
        obj[key] = this.sanitizeString(value);
      } else if (typeof value === 'object' && value !== null) {
        this.sanitizeAndCheckObject(value, context, req);
      }
    }
  }

  private sanitizeString(input: string): string {
    return input
      .trim()
      .replace(/[\x00-\x1F\x7F]/g, '')
      .replace(/'/g, "''")
      .substring(0, 1000);
  }

  private checkForMaliciousContent(input: string, context: string, req: Request): void {
    const decodedInput = decodeURIComponent(input.toLowerCase());
    
    for (const pattern of this.sqlPatterns) {
      if (pattern.test(decodedInput)) {
        this.securityLogger.logSqlInjectionAttempt(req, input);
        throw new Error(`SQL injection pattern detected in ${context}: ${input}`);
      }
    }

    for (const pattern of this.xssPatterns) {
      if (pattern.test(decodedInput)) {
        this.securityLogger.logXssAttempt(req, input);
        throw new Error(`XSS pattern detected in ${context}: ${input}`);
      }
    }

    for (const pattern of this.otherPatterns) {
      if (pattern.test(decodedInput)) {
        this.securityLogger.logSecurityEvent({
          type: 'SUSPICIOUS_ACTIVITY',
          severity: 'MEDIUM',
          ip: req.ip || 'unknown',
          userAgent: req.get('User-Agent'),
          endpoint: req.url,
          method: req.method,
          payload: { suspiciousData: input },
          message: `Suspicious pattern detected in ${context}: ${input}`,
        });
        throw new Error(`Suspicious pattern detected in ${context}: ${input}`);
      }
    }

    if (input.length > 10000) {
      this.securityLogger.logSecurityEvent({
        type: 'SUSPICIOUS_ACTIVITY',
        severity: 'HIGH',
        ip: req.ip || 'unknown',
        userAgent: req.get('User-Agent'),
        endpoint: req.url,
        method: req.method,
        message: `Excessively long input detected in ${context} (${input.length} characters)`,
      });
      throw new Error(`Excessively long input in ${context}`);
    }
  }

  private checkSuspiciousHeaders(req: Request): void {
    const userAgent = req.get('User-Agent');
    const referer = req.get('Referer');

    if (userAgent && (
      userAgent.includes('sqlmap') ||
      userAgent.includes('nikto') ||
      userAgent.includes('nmap') ||
      userAgent.length > 500
    )) {
      this.securityLogger.logSecurityEvent({
        type: 'SUSPICIOUS_ACTIVITY',
        severity: 'HIGH',
        ip: req.ip || 'unknown',
        userAgent,
        endpoint: req.url,
        method: req.method,
        message: `Suspicious User-Agent detected: ${userAgent}`,
      });
      throw new Error('Suspicious User-Agent detected');
    }

    if (referer && [...this.sqlPatterns, ...this.xssPatterns].some(pattern => pattern.test(referer))) {
      this.securityLogger.logSecurityEvent({
        type: 'SUSPICIOUS_ACTIVITY',
        severity: 'MEDIUM',
        ip: req.ip || 'unknown',
        userAgent,
        endpoint: req.url,
        method: req.method,
        message: `Suspicious Referer header detected: ${referer}`,
      });
      throw new Error('Suspicious Referer header detected');
    }
  }
}