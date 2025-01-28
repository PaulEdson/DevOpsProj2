import { __decorate } from "tslib";
import { Injectable } from '@angular/core';
let ApiService = class ApiService {
    http;
    constructor(http) {
        this.http = http;
    }
    getMessage(url) {
        // this.http.get(' input.txt', { responseType: 'text'}).subscribe(data => {
        //     this.url = data
        //     return this.http.get(this.url)
        // })
        console.log("in get message", url);
        return this.http.get("http://" + url
        //"http://localhost:3000"
        );
    }
    getUrl() {
        // return this.http.get('input.txt', {responseType: 'text'}).toPromise();
        // console.log(this.url)
        // return this.url
        return this.http.get('url.txt', { responseType: 'text' });
    }
};
ApiService = __decorate([
    Injectable({
        providedIn: 'root'
    })
], ApiService);
export { ApiService };
