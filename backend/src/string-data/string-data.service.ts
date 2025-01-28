import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { CreateStringDatumDto } from './dto/create-string-datum.dto';
import { UpdateStringDatumDto } from './dto/update-string-datum.dto';
import { stringdatum } from './entities/string-datum.entity';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
@Injectable()
export class StringDataService {
  constructor(@InjectRepository(stringdatum) private repo: Repository<stringdatum>){}

  async create(createStringDto: stringdatum): Promise<stringdatum> {
    await this.repo.exists({where:{stringId: createStringDto.stringId}}).then(exists => {
      if (exists){
        throw new HttpException(`string ID ${createStringDto.stringId} already exists`, HttpStatus.BAD_REQUEST)
      }
    })
    return await this.repo.save(createStringDto);
  }

  async findAll(): Promise<stringdatum[]> {
    console.log("service reached")
    return await this.repo.find();
  }

  async findOne(id: number) {
    console.log("service reached")
    return await this.repo.findOneOrFail({where:{stringId:id}});
  }

  //not implemented as the sample app just needs to create and read data from database
  update(id: number, updateStringDatumDto: UpdateStringDatumDto) {
    return `This action updates a #${id} stringDatum`;
  }

  //not implemented as the sample app just needs to create and read data from database
  remove(id: number) {
    return `This action removes a #${id} stringDatum`;
  }
}
