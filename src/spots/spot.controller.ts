import { Controller, Get, Param } from '@nestjs/common';
import { SpotService } from './spot.service';
import { Spot } from 'src/models/Spot';

@Controller('spot')
export class SpotController {
  constructor(private readonly spotService: SpotService) {}

  @Get()
  findAll() {
    return this.spotService.findAll();
  }
  @Get(':id')
  async find(@Param('id') id: string): Promise<Spot> {
    return this.spotService.find(id);
}

}