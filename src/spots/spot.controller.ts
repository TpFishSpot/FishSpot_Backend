import { Controller, Get } from '@nestjs/common';
import { SpotService } from './spot.service';

@Controller('spot')
export class SpotController {
  constructor(private readonly spotService: SpotService) {}

  @Get()
  findAll() {
    return this.spotService.findAll();
  }
}
