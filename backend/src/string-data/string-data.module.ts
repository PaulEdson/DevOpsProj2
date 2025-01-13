import { Module } from '@nestjs/common';
import { StringDataService } from './string-data.service';
import { StringDataController } from './string-data.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { stringdatum } from './entities/string-datum.entity';

@Module({
  imports:[TypeOrmModule.forFeature([stringdatum])],
  exports:[TypeOrmModule],
  controllers: [StringDataController],
  providers: [StringDataService],
})
export class StringDataModule {}
