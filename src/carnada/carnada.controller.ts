import { Controller, Get, Param } from '@nestjs/common';
import { CarnadaService } from './carnada.service';
import { Carnada } from 'src/models/Carnada';
import { Public } from 'src/auth/decorator';

@Controller('carnada')
export class CarnadaController {
  constructor(private readonly carnadaService: CarnadaService) {}

  @Get()
  @Public()
  findAll(): Promise<Carnada[]> {
    return this.carnadaService.findAll();
  }

  @Get(':id')
  @Public()
  findOne(@Param('id') id: string): Promise<Carnada | null> {
    return this.carnadaService.findOne(id);
  }

}
