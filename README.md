# 代码分析
---

1. Blockchian架构
	1-1 p2p Netwok
	1-2 BlockChain
	1-3 Block
	1-4 Transation
2. 开发规范
3. 开发技巧
	- Log前缀设定
	```
	func init() {
	log.SetPrefix("Blockchain: ")
	}	
	```
	- flag包，用来解析程序运行时的启动参数
	```
	//程序名 myapp.exe , 带有参数 - name， - ip， - port， - a 
	package main

	func main() {
		var name, ip, a string
		var port int

		flag.StringVar(&name, "name", "default name", "the name to use")
		flag.StringVar(&ip, "ip", "127.0.0.1", "the IP address to use")
		flag.IntVar(&port, "port", 8080, "the port number to use")
		flag.StringVar(&a, "a", "", "the a flag")

		flag.Parse()

		fmt.Println("name:", name)
		fmt.Println("ip:", ip)
		fmt.Println("port:", port)
		fmt.Println("a:", a)
	}
	```
	- 字符串转换的方法：fmt.Sprintf , strconv, string()
	  - fmt.Sprintf 用于格式化字符串
	```
	PreviousHash: fmt.Sprintf("%x", b.previousHash),
	```
	```
	ph, _ := hex.DecodeString(*v.PreviousHash)
	copy(b.previousHash[:], ph[:32])
	```
	  - strconv可以让其他基本类型与字符串互转 
	```
	  // str to int
	  	str := "42"
		i, err := strconv.Atoi(str)
      // int, float, bool to str
		i := 42
		str := strconv.Itoa(i)
		f := 3.14
		str := strconv.FormatFloat(f, 'f', -1, 64)
		b := true
		str := strconv.FormatBool(b)
	```
	  - string() ,可以用于把JSON或者[]byte转为str
	```
	  // JSON 字符串
		jsonStr := `{"name":"Alice","age":30}`

		// 将 JSON 字符串解析为 map 类型
		var data map[string]interface{}
		if err := json.Unmarshal([]byte(jsonStr), &data); err != nil {
			// 处理错误
		}

		// 将解析后的 map 类型转换为字符串类型
		str := string(data["name"].(string))
	```
	```
		// 字节数组
		bytes := []byte{97, 98, 99}

		// 将字节数组转换为字符串类型
		str := string(bytes)
	```
	- 序列化实践：复杂对象应该分别实现各种子结构的MarshalJSON

		>如果想要将区块链以及其中的区块和交易信息序列化为 JSON 格式，需要为 Blockchain、Block 和 Transaction 结构体分别实现 MarshalJSON() 方法。
		>在 Blockchain 结构体的 MarshalJSON() 方法中，可以通过创建一个匿名结构体，将所有的 Block 对象组成一个数组，然后使用 json.Marshal() 函数将该结构体序列化为 JSON 字符串。
		>类似地，在 Block 结构体的 MarshalJSON() 方法中，也需要创建一个匿名结构体，将该结构体中的各个字段赋值为 Block 对象中对应的>字段，并使用 json.Marshal() 函数将该结构体序列化为 JSON 对象。
		>同样地，在 Transaction 结构体的 MarshalJSON() 方法中，需要创建一个匿名结构体，并将该结构体中的各个字段赋值为 Transaction >对象中对应的字段。
		>完成上述实现后，可以调用 json.Marshal() 函数将 Blockchain 对象序列化为 JSON 字符串。在序列化过程中，Go 编译器会自动调用每个对象的 MarshalJSON() 方法，将其转换为对应的 JSON 对象。
	    >需要序列化的要写出MarshalJSON和UnmarshalJSON func
	```
	func (b *Block) MarshalJSON() ([]byte, error) {
		return json.Marshal(struct {
			Timestamp    int64          `json:"timestamp"`
			Nonce        int            `json:"nonce"`
			PreviousHash string         `json:"previous_hash"`
			Transactions []*Transaction `json:"transactions"`
		}{
			Timestamp:    b.timestamp,
			Nonce:        b.nonce,
			PreviousHash: fmt.Sprintf("%x", b.previousHash),
			Transactions: b.transactions,
		})
	}
	```
	```
	func (b *Block) UnmarshalJSON(data []byte) error {
		var previousHash string
		v := &struct {
			Timestamp    *int64          `json:"timestamp"`
			Nonce        *int            `json:"nonce"`
			PreviousHash *string         `json:"previous_hash"`
			Transactions *[]*Transaction `json:"transactions"`
		}{
			Timestamp:    &b.timestamp,
			Nonce:        &b.nonce,
			PreviousHash: &previousHash,
			Transactions: &b.transactions,
		}
		if err := json.Unmarshal(data, &v); err != nil {
			return err
		}
		ph, _ := hex.DecodeString(*v.PreviousHash)
		copy(b.previousHash[:], ph[:32])
		return nil
	}
	```
	- 序列化实践2：decoder.Decode()和json.Unmarshal()

		>都是用来将JSON数据反序列化为Go语言结构体对象的方法。不同之处在于它们接收的输入参数不同。
		>json.Unmarshal()接收一个[]byte类型的JSON数据作为输入参数，而decoder.Decode()接收一个实现了io.Reader接口的对象作为输入参数，比如http.Request.Body。
		>使用decoder.Decode()可以更方便地处理一些I/O相关的操作，比如从HTTP请求中读取JSON数据并将其反序列化为一个结构体对象。而json.Unmarshal()则更适合处理已经在内存中的JSON数据。

	```
	// 客户端序列化RequestBody
	func sendRequest() error {
		requestBody := struct {
			Name  string `json:"name"`
			Email string `json:"email"`
		}{
			Name:  "Alice",
			Email: "alice@example.com",
		}
		requestJson, err := json.Marshal(requestBody)
		if err != nil {
			return err
		}

		req, err := http.NewRequest(http.MethodPost, "http://example.com/api", bytes.NewBuffer(requestJson))
		if err != nil {
			return err
		}

		// 发送请求 ...
	}

	// 服务端反序列化取得值
	func handleRequest(w http.ResponseWriter, r *http.Request) {
		var requestBody struct {
			Name  string `json:"name"`
			Email string `json:"email"`
		}

		decoder := json.NewDecoder(r.Body)
		if err := decoder.Decode(&requestBody); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		fmt.Fprintf(w, "Name: %s\n", requestBody.Name)
		fmt.Fprintf(w, "Email: %s\n", requestBody.Email)
	}
	```
	- 序列化实践3：哈希值属于16进制编码
	```
	fmt.Sprintf("%x", b.previousHash)
	```
	```
	ph, _ := hex.DecodeString(*v.PreviousHash)
	copy(b.previousHash[:], ph[:32])
	```

	- 定时操作: 过一定秒数，再启动自身，另外在bc.Mining()中有互斥锁来确保在挖矿时
	只有一个 goroutine 能够访问区块链

	```
	func (bc *Blockchain) StartMining() {
		bc.Mining()
		_ = time.AfterFunc(time.Second*MINING_TIMER_SEC, bc.StartMining)
	}
	```
	```
	func (bc *Blockchain) Mining() bool {
		bc.mux.Lock()
		defer bc.mux.Unlock()
	```

	- 带参数发送Get请求：
	```
	//客户端	
	client := &http.Client{}
	bcsReq, _ := http.NewRequest("GET", endpoint, nil)
	q := bcsReq.URL.Query()
	q.Add("blockchain_address", blockchainAddress)
	bcsReq.URL.RawQuery = q.Encode()
	bcsResp, err := client.Do(bcsReq)
	```
	```
	//服务端
	func (bcs *BlockchainServer) Amount(w http.ResponseWriter, req *http.Request) {
		switch req.Method {
		case http.MethodGet:
			blockchainAddress := req.URL.Query().Get("blockchain_address")
			amount := bcs.GetBlockchain().CalculateTotalAmount(blockchainAddress)

			ar := &block.AmountResponse{Amount: amount}
			m, _ := ar.MarshalJSON()

			w.Header().Add("Content-Type", "application/json")
			io.WriteString(w, string(m[:]))

		default:
			log.Printf("ERROR: Invalid HTTP Method")
			w.WriteHeader(http.StatusBadRequest)
		}
	}

	```
	- OOP实践
	  - 建立一个结构体，每个属性都是私有属性，然后写出GetFunc
	  - 实现一个NewFunc，用来返回这个结构的指针，NewFunc不属于该结构体
	  - 实体类应该写出Print() func
	```
	  func (b *Block) Print() {
			fmt.Printf("timestamp       %d\n", b.timestamp)
			fmt.Printf("nonce           %d\n", b.nonce)
			fmt.Printf("previous_hash   %x\n", b.previousHash)
			for _, t := range b.transactions {
				t.Print()
			}
		}
	```
	  - 序列化操作参见上面
	  - 该结构体如果包含读写操作，考虑在属性中包含锁，sync.Mutex
	  - 复杂结构都用指针数组，不用实体

	- FindNeighbors
4. TODO List
5. 参考连接

# 知识点
Demo项目启动Kickoff，Q2 townhall
10:30-11:00
大屋

礼拜一 2：00-3：00







1. 使用copy进行字符串到byte数组转换

```	
    pHashStr := "Genesis Block"
	var pHash [32]byte
	copy(pHash[:], []byte(pHashStr))
```

2.

```	
使用 GCM 作为 WSL Git 安装的凭据帮助程序意味着默认情况下，GCM 不遵循 WSL Git 中的任何配置集， (默认情况下) 。 
这是因为 GCM 作为 Windows 应用程序运行，因此将使用适用于 Windows 安装的 Git 来查询配置。 这意味着 GCM 的
代理设置等内容需要在 Git for Windows 和 WSL Git 中设置，因为它们存储在不同文件中 (%USERPROFILE%\.gitconfig 
与 \\wsl$\distro\home\$USER\.gitconfig) 。 可以配置 WSL，以便 GCM 将使用 WSL Git 配置，但这意味着代理设置
对于特定 WSL 安装是唯一的，不会与他人或 Windows 主机共享。
```	

3
func (bc *Blockchain) VerifyTransactionSignature(
	senderPublicKey *ecdsa.PublicKey, s *utils.Signature, t *Transaction) bool {
	m, _ := json.Marshal(t)
	h := sha256.Sum256([]byte(m))

	// return ecdsa.Verify(senderPublicKey, h[:], s.R, s.S)
	return ecdsa.VerifyASN1(senderPublicKey, h[:], []byte(s.String()))
}

"github.com/ocean5tech/goblockchainwoo/utils"

4.

声明一个Struct，所有属性都私有
声明一个NewFunc
声明属性的GetFunc
声明工具Func
