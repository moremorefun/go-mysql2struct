package {{.PackageName}}

import (
    "bytes"
	"context"
	"fmt"
	"reflect"
	"strconv"
	"strings"

	"github.com/moremorefun/mcommon"
)

var globalIndex int64

// getK 获取key
func getK(old string) string {
	globalIndex++
	old = strings.ReplaceAll(old, ".", "_")
	old = strings.ReplaceAll(old, "`", "_")
	var buf bytes.Buffer
	buf.WriteString(old)
	buf.WriteString("_")
	buf.WriteString(strconv.FormatInt(globalIndex, 10))
	return buf.String()
}

{{range $i, $tableInfo := .Rows}}
// SQLCreate{{$tableInfo.TableNameCamel}} 创建
func SQLCreate{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, row *DB{{$tableInfo.TableNameCamel}}, isIgnore bool) (int64, error) {
    var lastID int64
    var err error
    query := strings.Builder{}
    query.WriteString("INSERT ")
    if isIgnore {
        query.WriteString("IGNORE ")
    }
    query.WriteString("INTO {{$tableInfo.TableName}} ( ")
    if row.ID > 0 {
        query.WriteString("\n{{(index $tableInfo.Cols 0).ColName}},")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
       {{- if $x }}
       {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
       {{- end}}
       {{- end }}
) VALUES ( `)
    if row.ID > 0 {
        query.WriteString("\n:{{(index $tableInfo.Cols 0).ColName}},")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    :{{$colInfo.ColName}}{{- if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
)`)
    lastID, err = mcommon.DbExecuteLastIDNamedContent(
        ctx,
        tx,
        query.String(),
        mcommon.H{
            {{- range $x, $colInfo := $tableInfo.Cols}}
            "{{$colInfo.ColName}}":row.{{$colInfo.ColNameCamel}},
            {{- end }}
        },
    )
    if err != nil {
        return 0, err
    }
    return lastID, nil
}

// SQLCreate{{$tableInfo.TableNameCamel}}Duplicate 创建更新
func SQLCreate{{$tableInfo.TableNameCamel}}Duplicate(ctx context.Context, tx mcommon.DbExeAble, row *DB{{$tableInfo.TableNameCamel}}, updates []string) (int64, error) {
    var lastID int64
    var err error
    query := strings.Builder{}
    query.WriteString("INSERT INTO {{$tableInfo.TableName}} ( ")
    if row.ID > 0 {
        query.WriteString("\n{{(index $tableInfo.Cols 0).ColName}},")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
       {{- if $x }}
       {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
       {{- end}}
       {{- end }}
) VALUES ( `)
    if row.ID > 0 {
        query.WriteString("\n:{{(index $tableInfo.Cols 0).ColName}},")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    :{{$colInfo.ColName}}{{- if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) `)
    updatesLen := len(updates)
    lastUpdateIndex := updatesLen - 1
    if updatesLen > 0 {
        query.WriteString("ON DUPLICATE KEY UPDATE\n")
        for i, update := range updates {
            query.WriteString(update)
            query.WriteString("=VALUES(")
            query.WriteString(update)
            query.WriteString(")")
            if i != lastUpdateIndex {
                query.WriteString(",\n")
            } else {
                query.WriteString("\n")
            }
        }
    }
    lastID, err = mcommon.DbExecuteLastIDNamedContent(
        ctx,
        tx,
        query.String(),
        mcommon.H{
            {{- range $x, $colInfo := $tableInfo.Cols}}
            "{{$colInfo.ColName}}":row.{{$colInfo.ColNameCamel}},
            {{- end }}
        },
    )
    if err != nil {
        return 0, err
    }
    return lastID, nil
}

// SQLCreateMany{{$tableInfo.TableNameCamel}} 创建多个
func SQLCreateMany{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, rows []*DB{{$tableInfo.TableNameCamel}}, isIgnore bool) (int64, error) {
    if len(rows) == 0 {
        return 0, nil
    }
	var args []interface{}
	if rows[0].ID > 0 {
	    for _, row := range rows {
            args = append(
                args,
                []interface{}{
                    {{- range $x, $colInfo := $tableInfo.Cols}}
                    row.{{$colInfo.ColNameCamel}},
                    {{- end }}
                },
            )
        }
	} else {
	    for _, row := range rows {
    		args = append(
    			args,
    			[]interface{}{
    			    {{- range $x, $colInfo := $tableInfo.Cols}}
    			    {{- if $x }}
                    row.{{$colInfo.ColNameCamel}},
                    {{- end }}
                    {{- end }}
    			},
    		)
    	}
	}
	var count int64
	var err error
	query := strings.Builder{}
    query.WriteString("INSERT ")
    if isIgnore {
        query.WriteString("IGNORE ")
    }
    query.WriteString("INTO {{$tableInfo.TableName}} ( ")
    if rows[0].ID > 0 {
        query.WriteString("\n{{(index $tableInfo.Cols 0).ColName}},")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES
    %s `)
    count, err = mcommon.DbExecuteCountManyContent(
        ctx,
        tx,
        query.String(),
        len(rows),
        args...,
    )
	if err != nil {
		return 0, err
	}
	return count, nil
}


// SQLCreateMany{{$tableInfo.TableNameCamel}}Duplicate 创建多个
func SQLCreateMany{{$tableInfo.TableNameCamel}}Duplicate(ctx context.Context, tx mcommon.DbExeAble, rows []*DB{{$tableInfo.TableNameCamel}}, updates []string) (int64, error) {
    if len(rows) == 0 {
        return 0, nil
    }
	var args []interface{}
	if rows[0].ID > 0 {
	    for _, row := range rows {
            args = append(
                args,
                []interface{}{
                    {{- range $x, $colInfo := $tableInfo.Cols}}
                    row.{{$colInfo.ColNameCamel}},
                    {{- end }}
                },
            )
        }
	} else {
	    for _, row := range rows {
    		args = append(
    			args,
    			[]interface{}{
    			    {{- range $x, $colInfo := $tableInfo.Cols}}
    			    {{- if $x }}
                    row.{{$colInfo.ColNameCamel}},
                    {{- end }}
                    {{- end }}
    			},
    		)
    	}
	}
	var count int64
	var err error
	query := strings.Builder{}
    query.WriteString("INSERT INTO {{$tableInfo.TableName}} ( ")
    if rows[0].ID > 0 {
        query.WriteString("\n{{(index $tableInfo.Cols 0).ColName}},")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES
    %s `)
    updatesLen := len(updates)
    lastUpdateIndex := updatesLen - 1
    if updatesLen > 0 {
        query.WriteString("ON DUPLICATE KEY UPDATE\n")
        for i, update := range updates {
            query.WriteString(update)
            query.WriteString("=VALUES(")
            query.WriteString(update)
            query.WriteString(")")
            if i != lastUpdateIndex {
                query.WriteString(",\n")
            } else {
                query.WriteString("\n")
            }
        }
    }
    count, err = mcommon.DbExecuteCountManyContent(
        ctx,
        tx,
        query.String(),
        len(rows),
        args...,
    )
	if err != nil {
		return 0, err
	}
	return count, nil
}

// SQLGet{{$tableInfo.TableNameCamel}}Col 根据id查询
func SQLGet{{$tableInfo.TableNameCamel}}Col(ctx context.Context, tx mcommon.DbExeAble, cols []string, id int64) (*DB{{$tableInfo.TableNameCamel}}, error) {
	query := strings.Builder{}
	query.WriteString("SELECT\n")
	query.WriteString(strings.Join(cols, ",\n"))
	query.WriteString(`
FROM
	{{$tableInfo.TableName}}
WHERE
	id=:id
LIMIT 1`)

	var row DB{{$tableInfo.TableNameCamel}}
	ok, err := mcommon.DbGetNamedContent(
		ctx,
		tx,
		&row,
		query.String(),
		mcommon.H{
			"id": id,
		},
	)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, nil
	}
	return &row, nil
}

// SQLGet{{$tableInfo.TableNameCamel}}ColKV 根据id查询
func SQLGet{{$tableInfo.TableNameCamel}}ColKV(ctx context.Context, tx mcommon.DbExeAble, cols []string, keys []string, values []interface{}) (*DB{{$tableInfo.TableNameCamel}}, error) {
	keysLen := len(keys)
    if keysLen != len(values) {
        return nil, fmt.Errorf("value len error")
    }

	query := strings.Builder{}
	query.WriteString("SELECT\n")
	query.WriteString(strings.Join(cols, ",\n"))
	query.WriteString(`
FROM
	{{$tableInfo.TableName}}
`)
    if len(keys) > 0 {
        query.WriteString("WHERE\n")
    }
    argMap := mcommon.H{}
    for i, key := range keys {
        k := getK(key)
        if i != 0 {
            query.WriteString("AND ")
        }
        value := values[i]
        query.WriteString(key)
        rt := reflect.TypeOf(value)
        switch rt.Kind() {
        case reflect.Slice:
            s := reflect.ValueOf(value)
            if s.Len() == 0 {
                return nil, nil
            }
            query.WriteString(" IN (:")
            query.WriteString(k)
            query.WriteString(")")
        default:
            query.WriteString("=:")
            query.WriteString(k)
        }
        query.WriteString("\n")
        argMap[k] = value
    }
    query.WriteString("LIMIT 1")

	var row DB{{$tableInfo.TableNameCamel}}
	ok, err := mcommon.DbGetNamedContent(
		ctx,
		tx,
		&row,
		query.String(),
		argMap,
	)
	if err != nil {
		return nil, err
	}
	if !ok {
		return nil, nil
	}
	return &row, nil
}

// SQLSelect{{$tableInfo.TableNameCamel}}Col 根据ids获取
func SQLSelect{{$tableInfo.TableNameCamel}}Col(ctx context.Context, tx mcommon.DbExeAble, cols []string, ids []int64, orderBys []string, limits []int64) ([]*DB{{$tableInfo.TableNameCamel}}, error) {
    if len(ids) == 0 {
        return nil, nil
    }
	query := strings.Builder{}
	query.WriteString("SELECT\n")
	query.WriteString(strings.Join(cols, ",\n"))
	query.WriteString(`
FROM
	{{$tableInfo.TableName}}
WHERE
	id IN (:ids)`)
	if len(orderBys) > 0 {
        query.WriteString("\nORDER BY\n")
        query.WriteString(strings.Join(orderBys, ",\n"))
        query.WriteString("\n")
	}
	if len(limits) == 1 {
        query.WriteString(fmt.Sprintf("LIMIT %d", limits[0]))
    }
    if len(limits) == 2 {
        query.WriteString(fmt.Sprintf("LIMIT %d,%d", limits[0], limits[1]))
    }
	var rows []*DB{{$tableInfo.TableNameCamel}}
	err := mcommon.DbSelectNamedContent(
		ctx,
		tx,
		&rows,
		query.String(),
		mcommon.H{
			"ids": ids,
		},
	)
	if err != nil {
		return nil, err
	}
	return rows, nil
}

// SQLSelect{{$tableInfo.TableNameCamel}}ColKV 根据ids获取
func SQLSelect{{$tableInfo.TableNameCamel}}ColKV(ctx context.Context, tx mcommon.DbExeAble, cols []string, keys []string, values []interface{}, orderBys []string, limits []int64) ([]*DB{{$tableInfo.TableNameCamel}}, error) {
    keysLen := len(keys)
    if keysLen != len(values) {
        return nil, fmt.Errorf("value len error")
    }

	query := strings.Builder{}
	query.WriteString("SELECT\n")
	query.WriteString(strings.Join(cols, ",\n"))
	query.WriteString(`
FROM
	{{$tableInfo.TableName}}
`)
    if len(keys) > 0 {
        query.WriteString("WHERE\n")
    }
    argMap := mcommon.H{}
    for i, key := range keys {
        k := getK(key)
        if i != 0 {
            query.WriteString("AND ")
        }
        value := values[i]
        query.WriteString(key)
        rt := reflect.TypeOf(value)
        switch rt.Kind() {
        case reflect.Slice:
            s := reflect.ValueOf(value)
            if s.Len() == 0 {
                return nil, nil
            }
            query.WriteString(" IN (:")
            query.WriteString(k)
            query.WriteString(")")
        default:
            query.WriteString("=:")
            query.WriteString(k)
        }
        query.WriteString("\n")
        argMap[k] = value
    }
    if len(orderBys) > 0 {
        query.WriteString("\nORDER BY\n")
        query.WriteString(strings.Join(orderBys, ",\n"))
        query.WriteString("\n")
    }
    if len(limits) == 1 {
        query.WriteString(fmt.Sprintf("LIMIT %d", limits[0]))
    }
    if len(limits) == 2 {
        query.WriteString(fmt.Sprintf("LIMIT %d,%d", limits[0], limits[1]))
    }

	var rows []*DB{{$tableInfo.TableNameCamel}}
	err := mcommon.DbSelectNamedContent(
		ctx,
		tx,
		&rows,
		query.String(),
		argMap,
	)
	if err != nil {
		return nil, err
	}
	return rows, nil
}

// SQLUpdate{{$tableInfo.TableNameCamel}} 更新
func SQLUpdate{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, row *DB{{$tableInfo.TableNameCamel}}) (int64, error) {
	count, err := mcommon.DbExecuteCountNamedContent(
		ctx,
		tx,
		`UPDATE
	{{$tableInfo.TableName}}
SET
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}=:{{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
WHERE
	id=:id`,
		mcommon.H{
		    {{- range $x, $colInfo := $tableInfo.Cols}}
            "{{$colInfo.ColName}}":row.{{$colInfo.ColNameCamel}},
            {{- end}}
		},
	)
	if err != nil {
		return 0, err
	}
	return count, nil
}

// SQLDelete{{$tableInfo.TableNameCamel}} 删除
func SQLDelete{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, id int64) (int64, error) {
	count, err := mcommon.DbExecuteCountNamedContent(
		ctx,
		tx,
		`DELETE
FROM
	{{$tableInfo.TableName}}
WHERE
	id=:id`,
		mcommon.H{
			"id": id,
		},
	)
	if err != nil {
		return 0, err
	}
	return count, nil
}

{{end}}
