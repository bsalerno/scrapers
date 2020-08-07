# scrapers

This repository contains different examples of scrapers that I have written. As a big sports fan, one great thing about sports is the availability of data. The only limiting factor is the technical expertise it takes to get the information you want!

#### NCAA Basketball

One ongoing project I had throughout my time in undergraduate studies was trying to model and predict NCAA Basketball games. At the time, I did not have much experience with databases, so I used flat CSV files for everything. While this was tedious, it made me feel a deeper appreciation for databases once I got more experience with them! The scrapers are written in Ruby, using the Mechanize library to make the web requests and the CSV library to deal with the "database" files. These were written in January of 2019 and replaced older scrapers that I had written in R in 2017.

#### NFL

In the year I spent at the University of Arkansas, I took a class that covered SQL, Python, and advanced Excel. The project at the end of the semester had to be focused on one of these tools, so I used Python. The objective of the project was to evaluate how well each NFL team was at identifying future performance by "redrafting" drafts from the past 15 or so years. The scrapers for the project used the requests_html library in Python. If you are interested in reading the results of this project, I have it written up [on my website](https://bsalerno.github.io/NFL_redraft.html).

#### eSports

With the 2020 coronavirus pandemic and lockdown, I was in need of sports to watch. Luckily, my good friend from high school and I had watched some eSports in the past, so I became interested in modeling team performance in Counter-Strike: Global Offensive. The main hub for Counter-Strike statistics is [HLTV.org](https://hltv.org), so I wrote some scrapers to pull the data that I wanted. I have included a small handful of these scrapers here. Instead of making these individual executable files, I used them to create an R package. This is why there are some weird comments on top of some of the scrapers, as it is to document the functions using a cool R package called Roxygen2.
