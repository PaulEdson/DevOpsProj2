import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { StringDataService } from './string-data.service';
import { CreateStringDatumDto } from './dto/create-string-datum.dto';
import { UpdateStringDatumDto } from './dto/update-string-datum.dto';
import { stringdatum } from './entities/string-datum.entity';

//string-data controller for add string data to the database
@Controller('string-data')
export class StringDataController {
  constructor(private readonly stringDataService: StringDataService) {}

  @Post()
  create(@Body() createStringDatum: stringdatum) {
    return this.stringDataService.create(createStringDatum);
  }

  @Get()
  findAll(): Promise<stringdatum[]> {
    console.log('controller reached')
    return this.stringDataService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: number): Promise<stringdatum> {
    console.log("controller reached")
    return this.stringDataService.findOne(id);
  }

  //patch and delete are not fully implemented as they are needed for the sample app
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateStringDatumDto: UpdateStringDatumDto) {
    return this.stringDataService.update(+id, updateStringDatumDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.stringDataService.remove(+id);
  }
}
