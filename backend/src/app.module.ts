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
    //env file that these are read from is added by the terraform file
    //will not work with localhost unless env file is added with connection parameters for a postgres database
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      username: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      //needs ssl certificate bundle from amazon to communicate with AWS database
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
