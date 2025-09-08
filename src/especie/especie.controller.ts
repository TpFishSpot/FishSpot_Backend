import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import { Carnada } from 'src/models/Carnada';
import { EspecieService } from './especie.service';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { TipoPescaEspecieDto } from './especie.repository';
import { Public } from 'src/auth/decorator';

@Controller('especie')
export class EspecieController {
  constructor(private readonly especieService: EspecieService) {}

  @Get('debug/count')
  @Public()
  async getDebugCount(): Promise<any> {
    try {
      const especies = await this.especieService.getEspecies();
      return {
        totalEspecies: especies.length,
        primerasEspecies: especies.slice(0, 5).map(e => ({
          id: e.id,
          nombre_cientifico: e.nombre_cientifico,
          nombre_comun: e.nombre_comun?.slice(0, 2)
        }))
      };
    } catch (error) {
      return { error: error.message };
    }
  }

  @Get()
  @Public()
  async getEspecies(): Promise<EspecieConNombreComun[]> {
    return this.especieService.getEspecies()
  }

  @Get(':id/carnadas')
  @Public()
  async getCarnadasRecomendadas( @Param('id') idEspecie: string): Promise<Carnada[]> {
    return this.especieService.findCarnadasRecomendadas(idEspecie);
  }

  @Get(':id')
  @Public()
  async findOne(@Param('id') idEspecie: string): Promise<EspecieConNombreComun>{
    return this.especieService.findOne(idEspecie);
  }

  @Get(':id/tipoPesca')
  @Public()
  async getTipoPesca( @Param('id') idEspecie: string): Promise<TipoPescaEspecieDto[]> {
    return this.especieService.getTiposPescaByEspecie(idEspecie);
  }
}
