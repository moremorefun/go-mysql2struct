package {{.PackageName}}

import (
	"context"
	"fmt"
	"strings"

	"github.com/moremorefun/mcommon"
)

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
    query.WriteString("INTO {{$tableInfo.TableName}} (\n")
    if row.ID > 0 {
        query.WriteString("{{(index $tableInfo.Cols 0).ColName}},\n")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
       {{- if $x }}
       {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
       {{- end}}
       {{- end }}
) VALUES (`)
    if row.ID > 0 {
        query.WriteString(":{{(index $tableInfo.Cols 0).ColName}},\n")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    :{{$colInfo.ColName}}{{- if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }})`)
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
    query.WriteString("INSERT INTO {{$tableInfo.TableName}} (\n")
    if row.ID > 0 {
        query.WriteString("{{(index $tableInfo.Cols 0).ColName}},\n")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
       {{- if $x }}
       {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
       {{- end}}
       {{- end }}
) VALUES (`)
    if row.ID > 0 {
        query.WriteString(":{{(index $tableInfo.Cols 0).ColName}},\n")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    :{{$colInfo.ColName}}{{- if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }})`)
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
    query.WriteString("INTO {{$tableInfo.TableName}} (\n")
    if rows[0].ID > 0 {
        query.WriteString("{{(index $tableInfo.Cols 0).ColName}},\n")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES
    %s`)
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
    query.WriteString("INSERT INTO {{$tableInfo.TableName}} (\n")
    if rows[0].ID > 0 {
        query.WriteString("{{(index $tableInfo.Cols 0).ColName}},\n")
    }
    query.WriteString(`{{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES
    %s`)
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
	id=:id`)

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
    if 0 == keysLen {
        return nil, fmt.Errorf("keys len error")
    }
    if keysLen != len(values) {
        return nil, fmt.Errorf("value len error")
    }

	query := strings.Builder{}
	query.WriteString("SELECT\n")
	query.WriteString(strings.Join(cols, ",\n"))
	query.WriteString(`
FROM
	{{$tableInfo.TableName}}
WHERE
`)
    argMap := mcommon.H{}
    for i, key := range keys {
        if i != 0 {
            query.WriteString("AND ")
        }
        value := values[i]
        query.WriteString(key)
        argValues, ok := value.([]interface{})
        if ok {
            if len(argValues) == 0 {
                return nil, nil
            }
            query.WriteString(" IN (:")
            query.WriteString(key)
            query.WriteString(" )")
        } else {
            query.WriteString("=:")
            query.WriteString(key)
        }
        query.WriteString("\n")
        argMap[key] = value
    }

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
func SQLSelect{{$tableInfo.TableNameCamel}}Col(ctx context.Context, tx mcommon.DbExeAble, cols []string, ids []int64, orderBys ...string) ([]*DB{{$tableInfo.TableNameCamel}}, error) {
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
func SQLSelect{{$tableInfo.TableNameCamel}}ColKV(ctx context.Context, tx mcommon.DbExeAble, cols []string, keys []string, values []interface{}, orderBys ...string) ([]*DB{{$tableInfo.TableNameCamel}}, error) {
    keysLen := len(keys)
    if 0 == keysLen {
        return nil, fmt.Errorf("keys len error")
    }
    if keysLen != len(values) {
        return nil, fmt.Errorf("value len error")
    }

	query := strings.Builder{}
	query.WriteString("SELECT\n")
	query.WriteString(strings.Join(cols, ",\n"))
	query.WriteString(`
FROM
	{{$tableInfo.TableName}}
WHERE
`)
    argMap := mcommon.H{}
    for i, key := range keys {
        if i != 0 {
            query.WriteString("AND ")
        }
        value := values[i]
        query.WriteString(key)
        argValues, ok := value.([]interface{})
        if ok {
            if len(argValues) == 0 {
                return nil, nil
            }
            query.WriteString(" IN (:")
            query.WriteString(key)
            query.WriteString(" )")
        } else {
            query.WriteString("=:")
            query.WriteString(key)
        }
        query.WriteString("\n")
        argMap[key] = value
    }
    if len(orderBys) > 0 {
        query.WriteString("\nORDER BY\n")
        query.WriteString(strings.Join(orderBys, ",\n"))
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
