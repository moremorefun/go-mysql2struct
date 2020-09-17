package {{.PackageName}}

{{if .IsTime}}
import "time"
{{end}}

// TableNames 所有表名
var TableNames = {{ .TableNamesStr }}

// 字段名
{{range $i, $tableInfo := .Rows}}
// const {{$tableInfo.TableNameCamel}} full
const (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    DBCol{{$tableInfo.TableNameCamel}}{{$colInfo.ColNameCamel}} = "{{$tableInfo.TableName}}.{{$colInfo.ColName}}" {{if $colInfo.IsColComment}} // {{$colInfo.ColComment}} {{end}}
    {{- end}}
)
// const {{$tableInfo.TableNameCamel}} short
const (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    DBColShort{{$tableInfo.TableNameCamel}}{{$colInfo.ColNameCamel}} = "{{$colInfo.ColName}}" {{if $colInfo.IsColComment}} // {{$colInfo.ColComment}} {{end}}
    {{- end}}
)
// DBCol{{$tableInfo.TableNameCamel}}All 所有字段
var DBCol{{$tableInfo.TableNameCamel}}All = []string{
{{- range $x, $colInfo := $tableInfo.Cols}}
    "{{$tableInfo.TableName}}.{{$colInfo.ColName}}",
{{- end}}
}

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
