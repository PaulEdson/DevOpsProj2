import { PartialType } from '@nestjs/mapped-types';
import { CreateStringDatumDto } from './create-string-datum.dto';

export class UpdateStringDatumDto extends PartialType(CreateStringDatumDto) {}
