# tk-proto

## Structure

- `proto/tk/v1/common_types.proto`: 通用请求/统一响应
- `proto/tk/v1/business_service.proto`: 业务域服务定义
- `proto/tk/v1/user_service.proto`: 用户域服务定义
- `proto/tk/v1/lottery_types.proto`: 彩票域 `data_json` 结构契约

## Generate

```bash
bash ./scripts/gen_proto.sh
```

当前彩票相关 RPC 仍然返回 `JsonDataReply`，但 `lottery_types.proto` 已经固化了
`data_json` 的结构定义，便于 `tk-admin`、`tk-business`、`tk-api` 和前端保持一致。
# tk-proto
# tk-proto
