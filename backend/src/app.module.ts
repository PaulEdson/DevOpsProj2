import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm'; //for type orm
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { StringDataModule } from './string-data/string-data.module';
import { stringdatum } from './string-data/entities/string-datum.entity'
import { StringDataController } from './string-data/string-data.controller';
import { StringDataService } from './string-data/string-data.service';
import { ConfigModule } from '@nestjs/config';
@Module({
  imports: [
    ConfigModule.forRoot(),
    // TypeOrmModule.forRoot({
    //   type: 'postgres',
    //   host: process.env.DATABASE_HOST,
    //   port: Number(process.env.DATABASE_PORT),
    //   username: process.env.DB_USER,
    //   password: process.env.DB_PASSWORD,
    //   database: process.env.DB_NAME,
    //   ssl: Boolean(Number(0)),
    //   synchronize: true, //if this is set to true, any changes made in the app will affect your schema
    //   entities: [stringdatum],
    // }),
    // StringDataModule
    ],
  controllers: [AppController, /*StringDataController*/],
  providers: [AppService, /*StringDataService*/],
})
export class AppModule {}
