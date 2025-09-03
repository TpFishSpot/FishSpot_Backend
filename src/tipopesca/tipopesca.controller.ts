import { Controller, Get, Param } from '@nestjs/common';
import { TipoPescaService } from './tipopesca.service';
import { TipoPesca } from 'src/models/TipoPesca';
import { Public } from 'src/auth/decorator';

@Controller('tipopesca')
export class TipoPescaController {
  constructor(private readonly tipoPescaService: TipoPescaService) {}

  @Get()
  @Public()
  findAll(): Promise<TipoPesca[]> {
    return this.tipoPescaService.findAll();
  }

  @Get(':id')
  @Public()
  findOne(@Param('id') id: string): Promise<TipoPesca | null> {
    return this.tipoPescaService.findOne(id);
  }
}
