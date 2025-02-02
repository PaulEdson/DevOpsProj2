import { StringData } from '../models/stringData';
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { catchError, Observable } from 'rxjs';

@Injectable({
    providedIn: 'root'
})
export class ApiService {
    constructor(private http: HttpClient) { }
    getMessage(url:string) {
        console.log("in get message", url)
        return this.http.get(
            //url read from file generated by terraform file
            "http://"+url+'/string-data'
            //"http://localhost:3000"
            );
            
            
    }

    //reads url from file generated by terraform file
    getUrl(){
        return this.http.get('url.txt', {responseType: 'text'})
    }

    /** POST: add a new hero to the database */
    addData(stringData: StringData, url:any): Observable<StringData> {
    return this.http.post<StringData>('http://'+url+'/string-data', stringData)
      .pipe(
        //catchError(this.handleError('addHero', hero))
      );
  }

}