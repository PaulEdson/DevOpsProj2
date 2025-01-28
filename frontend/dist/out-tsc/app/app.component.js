import { __decorate } from "tslib";
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
let AppComponent = class AppComponent {
    apiService;
    title = 'frontEnd';
    message;
    url;
    constructor(apiService) {
        this.apiService = apiService;
    }
    ;
    ngOnInit() {
        // this.apiService.getUrl().subscribe((data =>{
        //   console.log(data)
        //   this.url = data
        // }))
        // this.apiService.getMessage(this.url).subscribe(data => {
        //     this.message = data;
        //     console.log(this.message)
        // });
        this.apiService.getUrl().subscribe((url => {
            console.log(url);
            this.url = url;
            this.apiService.getMessage(this.url).subscribe(data => {
                this.message = data;
                console.log(this.message);
            });
        }));
    }
};
AppComponent = __decorate([
    Component({
        selector: 'app-root',
        imports: [RouterOutlet],
        templateUrl: './app.component.html',
        styleUrl: './app.component.css'
    })
], AppComponent);
export { AppComponent };
