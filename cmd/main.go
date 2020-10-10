package main

import (
	"database/sql"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

// 类型转换对应关系
var typeForMysqlToGo = map[string]string{
	"int":                "int64",
	"integer":            "int64",
	"tinyint":            "int64",
	"smallint":           "int64",
	"mediumint":          "int64",
	"bigint":             "int64",
	"int unsigned":       "int64",
	"integer unsigned":   "int64",
	"tinyint unsigned":   "int64",
	"smallint unsigned":  "int64",
	"mediumint unsigned": "int64",
	"bigint unsigned":    "int64",
	"bit":                "int64",
	"bool":               "bool",
	"enum":               "string",
	"set":                "string",
	"varchar":            "string",
	"char":               "string",
	"tinytext":           "string",
	"mediumtext":         "string",
	"text":               "string",
	"longtext":           "string",
	"blob":               "string",
	"tinyblob":           "string",
	"mediumblob":         "string",
	"longblob":           "string",
	"date":               "time.Time", // time.Time
	"datetime":           "time.Time", // time.Time
	"timestamp":          "time.Time", // time.Time
	"time":               "time.Time", // time.Time
	"float":              "float64",
	"double":             "float64",
	"decimal":            "string",
	"binary":             "string",
	"varbinary":          "string",
	"json":               "string",
}

// DbTable 表信息
type DbTable struct {
	TableName    string         `json:"table_name,omitempty" db:"table_name"`
	TableComment sql.NullString `json:"table_comment,omitempty" db:"table_comment"`
}

// DbColumn 列信息
type DbColumn struct {
	TableSchema   string         `json:"table_schema,omitempty" db:"table_schema"`
	TableName     string         `json:"table_name,omitempty" db:"table_name"`
	ColumnName    string         `json:"column_name,omitempty" db:"column_name"`
	DataType      string         `json:"data_type,omitempty" db:"data_type"`
	ColumnComment sql.NullString `json:"column_comment,omitempty" db:"column_comment"`
}

var numberSequence = regexp.MustCompile(`([a-zA-Z])(\d+)([a-zA-Z]?)`)
var numberReplacement = []byte(`$1 $2 $3`)

func addWordBoundariesToNumbers(s string) string {
	b := []byte(s)
	b = numberSequence.ReplaceAll(b, numberReplacement)
	return string(b)
}

// Converts a string to CamelCase
func toCamelInitCase(s string, initCase bool) string {
	s = addWordBoundariesToNumbers(s)
	s = strings.Trim(s, " ")
	n := ""
	capNext := initCase
	for _, v := range s {
		if v >= 'A' && v <= 'Z' {
			n += string(v)
		}
		if v >= '0' && v <= '9' {
			n += string(v)
		}
		if v >= 'a' && v <= 'z' {
			if capNext {
				n += strings.ToUpper(string(v))
			} else {
				n += string(v)
			}
		}
		if v == '_' || v == ' ' || v == '-' {
			capNext = true
		} else {
			capNext = false
		}
	}
	return n
}

// ToCamel Converts a string to CamelCase
func ToCamel(s string) string {
	c := toCamelInitCase(s, true)
	re := regexp.MustCompile(`Id$`)
	c = re.ReplaceAllString(c, `ID`)
	re = regexp.MustCompile(`Id([A-Z|0-9])`)
	c = re.ReplaceAllString(c, `ID$1`)

	re = regexp.MustCompile(`Ip$`)
	c = re.ReplaceAllString(c, `IP`)
	re = regexp.MustCompile(`Ip([A-Z|0-9])`)
	c = re.ReplaceAllString(c, `IP$1`)

	re = regexp.MustCompile(`Url$`)
	c = re.ReplaceAllString(c, `URL`)
	re = regexp.MustCompile(`Url([A-Z|0-9])`)
	c = re.ReplaceAllString(c, `URL$1`)

	re = regexp.MustCompile(`Uuid$`)
	c = re.ReplaceAllString(c, `UUID`)
	re = regexp.MustCompile(`Uuid([A-Z|0-9])`)
	c = re.ReplaceAllString(c, `UUID$1`)

	re = regexp.MustCompile(`Api$`)
	c = re.ReplaceAllString(c, `API`)
	re = regexp.MustCompile(`Api([A-Z|0-9])`)
	c = re.ReplaceAllString(c, `API$1`)

	return c
}

func main() {
	// 读取运行参数
	var dbUser = flag.String("user", "root", "数据库用户名")
	var dbPwd = flag.String("pwd", "123456", "数据库密码")
	var dbIPPort = flag.String("host", "127.0.0.1:3306", "数据库ip:端口")
	var dbName = flag.String("db", "", "数据库名")
	var packageName = flag.String("package", "model", "包名")
	var output = flag.String("o", "", "文件输出文件夹")
	var h = flag.Bool("h", false, "help message")
	flag.Parse()
	if *h {
		flag.Usage()
		return
	}
	if strings.TrimSpace(*dbName) == "" {
		flag.Usage()
		return
	}
	if strings.TrimSpace(*output) == "" {
		flag.Usage()
		return
	}
	dbDNS := fmt.Sprintf(
		"%s:%s@tcp(%s)/%s?parseTime=true&loc=Local&charset=utf8mb4&collation=utf8mb4_unicode_ci",
		*dbUser,
		*dbPwd,
		*dbIPPort,
		*dbName,
	)
	db, err := sqlx.Connect("mysql", dbDNS)
	if err != nil {
		log.Fatalf("db connect error: %s", err.Error())
	}
	err = db.Ping()
	if err != nil {
		log.Fatalf("db ping error: %s", err.Error())
	}

	// 获取所有表信息
	tableRows := make([]DbTable, 0)
	err = db.Select(
		&tableRows,
		`SELECT 
	table_name, 
	table_comment
FROM 
	information_schema.tables 
WHERE 
	table_schema=?
ORDER BY table_name`,
		*dbName,
	)
	if err != nil {
		log.Fatalf("db select error: %s", err.Error())
	}
	// 获取所有列信息
	colRows := make([]DbColumn, 0)
	err = db.Select(
		&colRows,
		`SELECT 
	table_schema, 
	table_name, 
	column_name, 
	data_type, 
	column_comment
FROM 
	information_schema.columns 
WHERE 
	table_schema=?
ORDER BY 
	table_name, 
	ordinal_position`,
		*dbName,
	)
	if err != nil {
		log.Fatalf("db select error: %s", err.Error())
	}

	// 整合数据
	isTime := false
	tableMap := make(map[string][]DbColumn)
	for _, colRow := range colRows {
		cols, ok := tableMap[colRow.TableName]
		if !ok {
			cols = make([]DbColumn, 0)
		}
		cols = append(cols, colRow)
		tableMap[colRow.TableName] = cols

		colGoType, ok := typeForMysqlToGo[colRow.DataType]
		if !ok {
			log.Fatalf("no type %s.%s %s", colRow.TableName, colRow.ColumnName, colRow.DataType)
		}
		if colGoType == "time.Time" {
			isTime = true
		}
	}

	// 列信息
	type stColInfo struct {
		ColName      string
		ColNameCamel string
		ColType      string
		IsColComment bool
		ColComment   string
		IsEnd        bool
	}
	// 表信息
	type stTableInfo struct {
		TableName      string
		TableNameCamel string
		TableComment   string
		Cols           []stColInfo
	}
	// 表数组
	var tableInfos []stTableInfo

	// 处理数据转换
	var tableNames []string
	for _, tableRow := range tableRows {
		tableName := tableRow.TableName
		cols, ok := tableMap[tableName]
		if !ok {
			log.Fatalf("no col of %s", tableName)
		}
		// 表数据
		tableNames = append(tableNames, fmt.Sprintf(`"%s"`, tableName))
		tableCamelName := ToCamel(tableName)
		tableComment := fmt.Sprintf("%s", tableRow.TableComment.String)
		tableComment = strings.Replace(tableComment, "\n", "-", -1)
		if tableRow.TableComment.Valid {
			tableComment = tableRow.TableComment.String
		}
		tableInfo := stTableInfo{
			TableName:      tableName,
			TableNameCamel: tableCamelName,
			TableComment:   tableComment,
		}
		// 列数据
		for i, col := range cols {
			colCamelName := ToCamel(col.ColumnName)
			colGoType, ok := typeForMysqlToGo[col.DataType]
			if !ok {
				log.Fatalf("no type %s", col.DataType)
			}
			commentStr := fmt.Sprintf("%s", col.ColumnComment.String)
			commentStr = strings.Replace(commentStr, "\n", "-", -1)
			tableInfo.Cols = append(tableInfo.Cols, stColInfo{
				ColName:      col.ColumnName,
				ColNameCamel: colCamelName,
				ColType:      colGoType,
				IsColComment: col.ColumnComment.Valid && col.ColumnComment.String != "",
				ColComment:   commentStr,
				IsEnd:        i == len(cols)-1,
			})
		}

		tableInfos = append(tableInfos, tableInfo)
	}
	// model 文件
	modelTpl, err := template.ParseFiles("template/model.tpl")
	if err != nil {
		log.Fatalf("cmd run error: %s", err)
	}
	modelInfo := struct {
		Rows          []stTableInfo
		PackageName   string
		HcommonPkg    string
		IsTime        bool
		TableNamesStr string
	}{
		Rows:          tableInfos,
		PackageName:   *packageName,
		IsTime:        isTime,
		TableNamesStr: "[]string{" + strings.Join(tableNames, ",") + "}",
	}
	modelFilePath := filepath.Join(*output, "db_gen_model.go")
	newModelFile, err := os.OpenFile(modelFilePath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		log.Fatalf("open file error: %s", err)
	}
	err = modelTpl.Execute(newModelFile, modelInfo)
	if err != nil {
		log.Fatalf("cmd run error: %s", err)
	}
	modelCmdSql := exec.Command("gofmt", "-w", modelFilePath)
	err = modelCmdSql.Run()
	if err != nil {
		log.Fatalf("cmd run error: %s", err)
	}

	// sql 文件
	sqlTpl, err := template.ParseFiles("template/sql.tpl")
	if err != nil {
		log.Fatalf("cmd run error: %s", err)
	}
	sqlFilePath := filepath.Join(*output, "db_gen_sql.go")
	newSqlFile, err := os.OpenFile(sqlFilePath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		log.Fatalf("open file error: %s", err)
	}
	info := struct {
		Rows        []stTableInfo
		PackageName string
		HcommonPkg  string
	}{
		Rows:        tableInfos,
		PackageName: *packageName,
	}
	err = sqlTpl.Execute(newSqlFile, info)
	if err != nil {
		log.Fatalf("cmd run error: %s", err)
	}
	cmdSql := exec.Command("gofmt", "-w", sqlFilePath)
	err = cmdSql.Run()
	if err != nil {
		log.Fatalf("cmd run error: %s", err)
	}
}
