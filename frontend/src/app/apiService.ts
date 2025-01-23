import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
@Injectable({
    providedIn: 'root'
})
export class ApiService {
    constructor(private http: HttpClient) { }
    getMessage(url:any) {
        
        // this.http.get(' input.txt', { responseType: 'text'}).subscribe(data => {
        //     this.url = data
        //     return this.http.get(this.url)
        // })
        console.log("in get message", url)
        return this.http.get(
            "http://"+url
            //"http://localhost:3000"
            );
            
            
    }

    getUrl(){
        // return this.http.get('input.txt', {responseType: 'text'}).toPromise();
        // console.log(this.url)
        // return this.url
        return this.http.get('url.txt', {responseType: 'text'})
    }
}