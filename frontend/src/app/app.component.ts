import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ApiService } from './services/apiService';
import {concatMap} from 'rxjs/operators'
import { StringData } from './models/stringData';
import { NgFor } from '@angular/common';
import { FormsModule } from '@angular/forms';
@Component({
  selector: 'app-root',
  imports: [RouterOutlet, NgFor, FormsModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  title = 'frontEnd';
  message: any;
  url: any;
  inputText:any
  constructor(private apiService: ApiService) { };
  ngOnInit() {
      // this.apiService.getUrl().subscribe((data =>{
      //   console.log(data)
      //   this.url = data
      // }))
      // this.apiService.getMessage(this.url).subscribe(data => {
      //     this.message = data;
      //     console.log(this.message)
      // });
      this.apiService.getUrl().subscribe((url =>{
        console.log(url)
        this.url = url

        this.apiService.getMessage(this.url).subscribe(data => {
          this.message = data
          console.log(this.message)
        })
        // let myString: StringData
        // myString = {
        //   stringId: 1000,
        //   stringValue: 'automated Value'
        // }
        // this.apiService.addHero(myString, url).subscribe();
      }))
  }
  myFunc(inputText:any){
    console.log(inputText);
    let myString: StringData
    myString = {
      stringId:1000,
      stringValue: inputText
    }
    this.apiService.addHero(myString, this.url).subscribe(inputText =>{
      this.apiService.getMessage(this.url).subscribe(data => {
        this.message = data
        console.log(this.message)
      })
    })
  }
  
}
