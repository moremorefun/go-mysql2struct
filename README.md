# go-mysql2struct

[![build](https://github.com/moremorefun/go-mysql2struct/workflows/build/badge.svg)](https://github.com/moremorefun/go-mysql2struct/actions?query=workflow%3Abuild)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://github.com/moremorefun/go-mysql2struct/blob/master/LICENSE)
[![blog](https://img.shields.io/badge/blog-@moremorefun-brightgreen.svg)](https://www.jidangeng.com)


## 目录

- [go-mysql2struct](#go-mysql2struct)
  - [目录](#目录)
  - [背景](#背景)
  - [使用说明](#使用说明)
  - [维护者](#维护者)
  - [使用许可](#使用许可)

## 背景

编写golang程序的时候需要把数据库的表建构转换为struct，而且很多时候数据库的操作基本统一。于是编写了一个根据表结构自动生成struct和通用数据处理函数的功能。


## 使用说明

```
go run cmd/main.go
Usage of :
  -db string
    	数据库名
  -h	help message
  -host string
    	数据库ip:端口 (default "127.0.0.1:3306")
  -o string
    	文件输出文件夹
  -package string
    	包名 (default "model")
  -pwd string
    	数据库密码 (default "123456")
  -user string
    	数据库用户名 (default "root")
```
   
## 维护者

[@moremorefun](https://github.com/moremorefun)
[那些年我们De过的Bug](https://www.jidangeng.com)

## 使用许可

[MIT](LICENSE) © moremorefun
