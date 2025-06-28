import { Body, Controller, Get, Post,Param } from '@nestjs/common';
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
  @Get(':id')
  async find(@Param('id') id: string): Promise<SpotDto> {
    const spot = await this.spotService.find(id);
    return  spot;                                         //TODO : verificar bien LA Convercion de las Entidades Y el retorno De DTOS
  }
  @Post()
  async ageregarSpot(@Body() spotDto: Spot) {
    return await this.spotService.agregarSpot(spotDto);
  }
}
