import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ApiService } from './apiService';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  title = 'frontEnd';
  message: any;
  constructor(private apiService: ApiService) { };
  ngOnInit() {
      this.apiService.getMessage().subscribe(data => {
          this.message = data;
          console.log(this.message)
      });
  }
}
