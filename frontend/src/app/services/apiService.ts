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
        
        // this.http.get(' input.txt', { responseType: 'text'}).subscribe(data => {
        //     this.url = data
        //     return this.http.get(this.url)
        // })
        console.log("in get message", url)
        return this.http.get(
            "http://"+url+'/string-data'
            //"http://localhost:3000"
            );
            
            
    }

    getUrl(){
        // return this.http.get('input.txt', {responseType: 'text'}).toPromise();
        // console.log(this.url)
        // return this.url
        return this.http.get('url.txt', {responseType: 'text'})
    }

    /** POST: add a new hero to the database */
    addHero(stringData: StringData, url:any): Observable<StringData> {
    return this.http.post<StringData>('http://'+url+'/string-data', stringData)
      .pipe(
        //catchError(this.handleError('addHero', hero))
      );
  }

}