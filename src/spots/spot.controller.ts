import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { SpotService } from './spot.service';
import { SpotDto } from 'src/dto/SpotDto';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';

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

  @Get(':id')
  async find(@Param('id') id: string): Promise<Spot> {
    return this.spotService.find(id);
  }

  @Get('/:id/especies')
  async findAllEspecies(@Param('id') id: string): Promise<EspecieConNombreComun[]> {
    return await this.spotService.findAllEspecies(id);
  }
}
