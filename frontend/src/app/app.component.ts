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
  //on page access retrieves all data currently in the database
  ngOnInit() {
      this.apiService.getUrl().subscribe((url =>{
        console.log(url)
        this.url = url

        this.apiService.getMessage(this.url).subscribe(data => {
          this.message = data
          console.log(this.message)
        })
      }))
  }
  //wraps data and passes it to the apiService
  sendInputData(inputText:any){
    console.log(inputText);
    let myString: StringData
    myString = {
      stringId:1000,
      stringValue: inputText
    }
    //sends data to the backend via http post request
    this.apiService.addData(myString, this.url).subscribe(inputText =>{
      this.apiService.getMessage(this.url).subscribe(data => {
        this.message = data
        console.log(this.message)
      })
    })
  }
  
}
