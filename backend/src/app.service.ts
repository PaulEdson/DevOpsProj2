import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return '{"stringId":1,"stringValue":"data in devops-proj2 database"}';
  }
  getData(): string {
    return '{"stringId":2,"stringValue":"I am also in the database"}'
  }
}
