import { Body, Controller, Get, Post } from '@nestjs/common';
import { SpotService } from './spot.service';
import { Spot } from 'src/models/Spot';
import { SpotDto } from 'src/dto/SpotDto';

@Controller('spot')
export class SpotController {
  constructor(private readonly spotService: SpotService) {}

  @Get()
  findAll() {
    return this.spotService.findAll();
  }

  @Post()
  async ageregarSpot(@Body() spotDto: SpotDto) {
    return await this.spotService.agregarSpot(spotDto);
  }
}
