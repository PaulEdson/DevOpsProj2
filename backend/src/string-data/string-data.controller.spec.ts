import { Test, TestingModule } from '@nestjs/testing';
import { StringDataController } from './string-data.controller';
import { StringDataService } from './string-data.service';

describe('StringDataController', () => {
  let controller: StringDataController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [StringDataController],
      providers: [StringDataService],
    }).compile();

    controller = module.get<StringDataController>(StringDataController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
