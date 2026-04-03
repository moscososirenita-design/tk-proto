# tk-proto - gRPC Proto 定义和代码生成

## 项目概述

`tk-proto` 定义了整个微服务体系的 gRPC 服务接口和数据结构。使用 Protocol Buffers（protobuf）作为 IDL（接口定义语言），通过代码生成工具生成各语言的 gRPC 代码。

**项目类型**: Proto 定义库  
**使用场景**: 
- 定义微服务间的 RPC 接口
- 定义统一的数据结构和消息格式
- 生成 Go、Java、Python 等语言的代码

## 项目结构

```
tk-proto/
├── proto/                              # protobuf 源文件目录
│   └── tk/v1/
│       ├── common.proto               # 通用类型（HomeOverviewRequest、JsonDataReply 等）
│       ├── business.proto             # 业务域 RPC 定义（彩票、投票、直播）
│       └── user.proto                 # 用户域 RPC 定义（认证、论坛）
├── gen/                                # 代码生成输出目录
│   ├── go/                            # Go 代码生成
│   │   ├── common/                    # 通用类型 Go 代码
│   │   ├── business/                  # 业务域 Go 代码
│   │   └── user/                      # 用户域 Go 代码
│   └── ...其他语言生成代码
├── scripts/
│   └── gen_proto.sh                   # Proto 代码生成脚本
├── go.mod                             # 模块定义
├── go.sum                             # 依赖版本锁定
└── README.md                          # 本文件
```

## Proto 文件说明

### common.proto - 通用消息定义
定义所有服务共用的消息类型和枚举：

**主要消息**:
- `HomeOverviewRequest` - 首页请求
- `CategoryLibraryRequest` - 分类查询请求
- `IDRequest` - 通用 ID 请求（用于查询单一资源）
- `JsonDataReply` - 统一 JSON 响应（code、msg、data）
- `VoteRecordRequest` / `VoteRequest` - 投票相关请求

**设计特点**:
- `JsonDataReply` 中的 `data` 字段为 JSON 字符串，用于灵活传输业务数据
- `code` 字段用于业务错误码（非 gRPC 状态码）
- 所有请求都包含 device_id、client_ip、user_agent 等设备标识

### business.proto - 业务域服务定义
定义业务服务（彩票、投票、直播现场）的 RPC 接口：

**BusinessService RPC 方法**:
- `HomeOverview()` - 首页聚合接口
- `LotteryDashboard()` - 开奖看板
- `DrawHistory()` - 开奖历史
- `DrawDetail()` - 开奖详情
- `LotteryDetail()` - 彩票详情
- `LotteryHistory()` - 彩票历史
- `LotteryResults()` - 彩票结果
- `ListCards()` - 彩种卡片列表
- `Vote()` / `VoteRecord()` - 投票及投票记录
- `LiveScenePage()` - 开奖现场页面

**数据结构**:
- `LotteryDashboardReply` - 开奖看板响应
- `LotteryHistoryReply` - 彩票历史响应
- `LotteryDrawDetailReply` - 开奖详情响应
- `LotteryDetailReply` - 彩票详情响应
- `ListCardsRequest` - 卡片列表请求

### user.proto - 用户域服务定义
定义用户服务（认证、论坛）的 RPC 接口：

**UserService RPC 方法**:
- `SignUp()` - 用户注册
- `SignIn()` - 用户登录
- `RefreshToken()` - 令牌刷新
- `ForumTopics()` - 论坛帖子列表
- `ForumTopicDetail()` - 帖子详情
- `ForumTopicAdd()` - 发布帖子
- `ForumComments()` - 评论列表
- 等其他论坛相关 RPC

## 代码生成

### 生成 Go 代码

```bash
cd /Users/leo/go-code/tk-proto
bash ./scripts/gen_proto.sh
```

该脚本会：
1. 编译 `proto/tk/v1/*.proto` 文件
2. 使用 protoc 和 protoc-gen-go、protoc-gen-go-grpc 插件
3. 生成 Go 代码到 `gen/go/` 目录
4. 生成的代码包含：
   - 消息的序列化/反序列化代码
   - gRPC 服务接口和客户端代码

### 使用生成的代码

**在业务服务中**:
```go
import (
    business "github.com/moscososirenita-design/tk-proto/gen/go/business"
    "github.com/moscososirenita-design/tk-proto/gen/go/common"
)

// 实现 BusinessService 接口
func (s *BusinessServer) HomeOverview(ctx context.Context, req *common.HomeOverviewRequest) (*common.JsonDataReply, error) {
    // 业务实现
}
```

**在网关中调用**:
```go
conn, _ := grpc.Dial("localhost:50052")
client := business.NewBusinessServiceClient(conn)
reply, _ := client.HomeOverview(ctx, &common.HomeOverviewRequest{})
```

## 修改 Proto 定义后的工作流

1. **编辑 `.proto` 文件**
   ```bash
   vim proto/tk/v1/business.proto
   ```

2. **生成新的 Go 代码**
   ```bash
   bash scripts/gen_proto.sh
   ```

3. **提交新生成的代码**
   ```bash
   git add gen/go/
   git commit -m "chore: regenerate proto code"
   ```

4. **在各依赖项目更新导入**
   ```bash
   # tk-business, tk-user, tk-api 等
   cd /Users/leo/go-code/tk-business
   go get -u github.com/moscososirenita-design/tk-proto
   go mod tidy
   ```

5. **编译验证**
   ```bash
   go build ./...
   ```

## 最佳实践

### Proto 设计原则

1. **向后兼容** - 新增字段时，始终使用新的字段号，不要删除旧字段
2. **版本管理** - 在命名空间中体现版本（如 `tk/v1/`）
3. **消息复用** - 尽量复用通用消息，减少冗余定义
4. **文档注释** - 为每个消息、字段、RPC 方法添加 godoc 注释

### 示例：添加新的 RPC 方法

```protobuf
// proto/tk/v1/business.proto

service BusinessService {
  // 新增方法
  // 功能: 获取我的投票记录
  // 请求: 投票信息 ID
  // 响应: 投票结果（JSON 格式）
  rpc GetMyVotes (IDRequest) returns (JsonDataReply);
}
```

然后执行生成脚本并在各服务中实现该方法。

## 常见错误处理

### protoc 找不到
确保 protoc 已安装：
```bash
brew install protobuf  # macOS
apt-get install protobuf-compiler  # Linux
```

### 生成代码导入错误
检查 `go.mod` 中 tk-proto 的版本是否与生成代码一致：
```bash
go mod tidy
```

## 相关项目依赖

- **tk-api**: 导入 `tk-proto/gen/go/business`、`tk-proto/gen/go/common`
- **tk-business**: 导入并实现 `business.proto` 中的 gRPC 服务
- **tk-user**: 导入并实现 `user.proto` 中的 gRPC 服务
- **tk-admin**: 导入相关 proto 消息用于数据序列化

## 工具链依赖

- **protoc** - Protocol Buffer 编译器
- **protoc-gen-go** - Go 语言代码生成插件
- **protoc-gen-go-grpc** - Go gRPC 服务代码生成插件
- **Go 1.24+** - 编译环境

---

**最后更新**: 2026-04-02  
**主要维护**: 数据结构和 RPC 接口定义
