import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm'; //for type orm
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { StringDataModule } from './string-data/string-data.module';
import { stringdatum } from './string-data/entities/string-datum.entity'
import { StringDataController } from './string-data/string-data.controller';
import { StringDataService } from './string-data/string-data.service';
import { ConfigModule } from '@nestjs/config';
const fs = require('fs')
@Module({
  imports: [
    ConfigModule.forRoot(),
    TypeOrmModule.forRoot({
      // type: 'postgres',
      // host: process.env.DB_HOST,
      // port: Number(process.env.DB_PORT),
      // username: process.env.DB_USER,
      // password: process.env.DB_PASSWORD,
      // database: process.env.DB_NAME,
      // ssl: Boolean(Number(0)),
      type: 'postgres',
      host: 'terraform-20250127210856115000000003.cnw80qoe8meq.us-east-1.rds.amazonaws.com',
      port: 5432,
      username: 'postgres',
      password: 'y1ew1Fx3W0QwwGSD8EyQ',
      database: 'private_db_pje',
      ssl: { 
        rejectUnauthorized: true,
        ca: fs.readFileSync('./us-east-1-bundle.pem').toString(), 
      } ,
      synchronize: true, //if this is set to true, any changes made in the app will affect your schema
      entities: [stringdatum],
    }),
    StringDataModule
    ],
  controllers: [AppController, StringDataController],
  providers: [AppService, StringDataService],
})
export class AppModule {}
