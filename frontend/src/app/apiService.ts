import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
@Injectable({
    providedIn: 'root'
})
export class ApiService {
    constructor(private http: HttpClient) { }
    getMessage() {
        return this.http.get(
            //'http://localhost:3000/string-data/1');
            'http://localhost:3000');
    }
}