
import { Column, Entity, PrimaryGeneratedColumn, Unique } from "typeorm";

@Entity()
export class stringdatum {
    @PrimaryGeneratedColumn()
    stringId: number;

    @Column()
    stringValue: string;

}

