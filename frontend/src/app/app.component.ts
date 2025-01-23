import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ApiService } from './apiService';
import {concatMap} from 'rxjs/operators'
@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  title = 'frontEnd';
  message: any;
  url: any;
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
      }))
  }
  
}
