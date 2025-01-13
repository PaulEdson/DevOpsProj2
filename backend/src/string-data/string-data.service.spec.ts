import { Test, TestingModule } from '@nestjs/testing';
import { StringDataService } from './string-data.service';

describe('StringDataService', () => {
  let service: StringDataService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [StringDataService],
    }).compile();

    service = module.get<StringDataService>(StringDataService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
