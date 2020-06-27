package {{.PackageName}}

{{if .IsTime}}
import "time"
{{end}}

// TableNames 所有表名
var TableNames = {{ .TableNamesStr }}

// 字段名
{{range $i, $tableInfo := .Rows}}
// const {{$tableInfo.TableNameCamel}}
const (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    DBCol{{$tableInfo.TableNameCamel}}{{$colInfo.ColNameCamel}} = "{{$tableInfo.TableName}}.{{$colInfo.ColName}}" {{if $colInfo.IsColComment}} // {{$colInfo.ColComment}} {{end}}
    {{- end}}
)

// 表结构
// DB{{$tableInfo.TableNameCamel}} {{$tableInfo.TableName}} {{ $tableInfo.TableComment}}
/*
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
*/
type DB{{$tableInfo.TableNameCamel}} struct {
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColNameCamel}} {{$colInfo.ColType}}  `db:"{{$colInfo.ColName}}" json:"{{$colInfo.ColName}}"` {{if $colInfo.IsColComment}} // {{$colInfo.ColComment}} {{end}}
    {{- end}}
}
{{end}}
