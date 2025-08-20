import { Controller, Get, Param } from '@nestjs/common';
import { CarnadaService } from './carnada.service';
import { Carnada } from 'src/models/Carnada';

@Controller('carnada')
export class CarnadaController {
  constructor(private readonly carnadaService: CarnadaService) {}

}
