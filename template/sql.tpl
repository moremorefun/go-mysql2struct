package {{.PackageName}}

import (
	"context"
	"strings"
	"github.com/moremorefun/mcommon"
)

type H map[string]interface{}

{{range $i, $tableInfo := .Rows}}
// SQLCreate{{$tableInfo.TableNameCamel}} 创建
func SQLCreate{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, row *DB{{$tableInfo.TableNameCamel}}) (int64, error) {
    var lastID int64
    var err error
    if row.ID > 0 {
        lastID, err = mcommon.DbExecuteLastIDNamedContent(
            ctx,
            tx,
            `INSERT INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end }}
) VALUES (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    :{{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end }}
)`,
            H{
                {{- range $x, $colInfo := $tableInfo.Cols}}
                "{{$colInfo.ColName}}":row.{{$colInfo.ColNameCamel}},
                {{- end }}
            },
        )
    } else {
        lastID, err = mcommon.DbExecuteLastIDNamedContent(
        	ctx,
        	tx,
        	`INSERT INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    :{{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
)`,
            H{
                {{- range $x, $colInfo := $tableInfo.Cols}}
                {{- if $x }}
                "{{$colInfo.ColName}}":row.{{$colInfo.ColNameCamel}},
                {{- end}}
                {{- end }}
            },
        )
    }
	if err != nil {
		return 0, err
	}
	return lastID, nil
}

// SQLCreateIgnore{{$tableInfo.TableNameCamel}} 创建
func SQLCreateIgnore{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, row *DB{{$tableInfo.TableNameCamel}}) (int64, error) {
	var lastID int64
        var err error
        if row.ID > 0 {
            lastID, err = mcommon.DbExecuteLastIDNamedContent(
                ctx,
                tx,
                `INSERT IGNORE INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end }}
) VALUES (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    :{{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end }}
)`,
                H{
                    {{- range $x, $colInfo := $tableInfo.Cols}}
                    "{{$colInfo.ColName}}":row.{{$colInfo.ColNameCamel}},
                    {{- end }}
                },
            )
        } else {
            lastID, err = mcommon.DbExecuteLastIDNamedContent(
            	ctx,
            	tx,
            	`INSERT IGNORE INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    :{{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
)`,
                H{
                    {{- range $x, $colInfo := $tableInfo.Cols}}
                    {{- if $x }}
                    "{{$colInfo.ColName}}":row.{{$colInfo.ColNameCamel}},
                    {{- end}}
                    {{- end }}
                },
            )
        }
	if err != nil {
		return 0, err
	}
	return lastID, nil
}

// SQLCreateMany{{$tableInfo.TableNameCamel}} 创建多个
func SQLCreateMany{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, rows []*DB{{$tableInfo.TableNameCamel}}) (int64, error) {
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
	if rows[0].ID > 0 {
        count, err = mcommon.DbExecuteCountManyContent(
            ctx,
            tx,
            `INSERT INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end }}
) VALUES
    %s`,
            len(rows),
            args...,
        )
	} else {
	    count, err = mcommon.DbExecuteCountManyContent(
            ctx,
            tx,
            `INSERT INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES
    %s`,
            len(rows),
            args...,
        )
	}
	if err != nil {
		return 0, err
	}
	return count, nil
}

// SQLCreateIgnoreMany{{$tableInfo.TableNameCamel}} 创建多个
func SQLCreateIgnoreMany{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, rows []*DB{{$tableInfo.TableNameCamel}}) (int64, error) {
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
    if rows[0].ID > 0 {
        count, err = mcommon.DbExecuteCountManyContent(
            ctx,
            tx,
            `INSERT IGNORE INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end }}
) VALUES
    %s`,
            len(rows),
            args...,
        )
    } else {
        count, err = mcommon.DbExecuteCountManyContent(
            ctx,
            tx,
            `INSERT IGNORE INTO {{$tableInfo.TableName}} (
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{- if $x }}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
    {{- end }}
) VALUES
    %s`,
            len(rows),
            args...,
        )
    }
    if err != nil {
        return 0, err
    }
    return count, nil
}

// SQLGet{{$tableInfo.TableNameCamel}} 根据id查询
func SQLGet{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, id int64) (*DB{{$tableInfo.TableNameCamel}}, error) {
	var row DB{{$tableInfo.TableNameCamel}}
	ok, err := mcommon.DbGetNamedContent(
		ctx,
		tx,
		&row,
		`SELECT
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
FROM
	{{$tableInfo.TableName}}
WHERE
	id=:id`,
		H{
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
		H{
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

// SQLSelect{{$tableInfo.TableNameCamel}} 根据ids获取
func SQLSelect{{$tableInfo.TableNameCamel}}(ctx context.Context, tx mcommon.DbExeAble, ids []int64) ([]*DB{{$tableInfo.TableNameCamel}}, error) {
    if len(ids) == 0 {
		return nil, nil
	}
	var rows []*DB{{$tableInfo.TableNameCamel}}
	err := mcommon.DbSelectNamedContent(
		ctx,
		tx,
		&rows,
		`SELECT
    {{- range $x, $colInfo := $tableInfo.Cols}}
    {{$colInfo.ColName}}{{if not $colInfo.IsEnd  }},{{end}}
    {{- end}}
FROM
	{{$tableInfo.TableName}}
WHERE
	id IN (:ids)`,
		H{
			"ids": ids,
		},
	)
	if err != nil {
		return nil, err
	}
	return rows, nil
}

// SQLSelect{{$tableInfo.TableNameCamel}}Col 根据ids获取
func SQLSelect{{$tableInfo.TableNameCamel}}Col(ctx context.Context, tx mcommon.DbExeAble, cols []string, ids []int64) ([]*DB{{$tableInfo.TableNameCamel}}, error) {
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

	var rows []*DB{{$tableInfo.TableNameCamel}}
	err := mcommon.DbSelectNamedContent(
		ctx,
		tx,
		&rows,
		query.String(),
		H{
			"ids": ids,
		},
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
		H{
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
		H{
			"id": id,
		},
	)
	if err != nil {
		return 0, err
	}
	return count, nil
}

{{end}}