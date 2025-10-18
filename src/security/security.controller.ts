import { Controller, Get, UseGuards } from '@nestjs/common';
import { SecurityLogger } from '../security/security-logger.service';
import { Roles } from '../auth/decorator';
import { UserRole } from '../auth/enums/roles.enum';

@Controller('security')
export class SecurityController {
  constructor(private readonly securityLogger: SecurityLogger) {}

  @Get('summary')
  @Roles(UserRole.MODERATOR)
  getSecuritySummary() {
    return {
      last24Hours: this.securityLogger.getSecuritySummary(24),
      lastWeek: this.securityLogger.getSecuritySummary(168),
      lastMonth: this.securityLogger.getSecuritySummary(720),
    };
  }

  @Get('health')
  @Roles(UserRole.MODERATOR)
  getSecurityHealth() {
    const summary = this.securityLogger.getSecuritySummary(1);
    
    const criticalEvents = summary.bySeverity?.['CRITICAL'] || 0;
    const highEvents = summary.bySeverity?.['HIGH'] || 0;
    
    let status = 'HEALTHY';
    let message = 'Sistema funcionando normalmente';
    
    if (criticalEvents > 0) {
      status = 'CRITICAL';
      message = `${criticalEvents} eventos críticos detectados en la última hora`;
    } else if (highEvents > 5) {
      status = 'WARNING';
      message = `${highEvents} eventos de alta severidad detectados en la última hora`;
    } else if (summary.totalEvents > 100) {
      status = 'WARNING';
      message = `Alto volumen de eventos de seguridad: ${summary.totalEvents}`;
    }
    
    return {
      status,
      message,
      timestamp: new Date(),
      metrics: summary,
    };
  }
}