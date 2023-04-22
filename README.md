# 代码分析
---
### Blockchian架构
1. p2p Netwok
2. BlockChain
3. Block
4. Transation
### 开发规范
### 开发技巧
1. Log前缀设定 log.SetPrefix
	```
	func init() {
	log.SetPrefix("Blockchain: ")
	}	
	```
2. flag包，用来解析程序运行时的启动参数
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
3. 字符串转换的方法：fmt.Sprintf , strconv, string()，使用copy进行字符串到byte数组转换
	>fmt.Sprintf 用于格式化字符串
	```
	PreviousHash: fmt.Sprintf("%x", b.previousHash),
	```
	```
	ph, _ := hex.DecodeString(*v.PreviousHash)
	copy(b.previousHash[:], ph[:32])
	```
	>strconv可以让其他基本类型与字符串互转 
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
	>string() ,可以用于把JSON或者[]byte转为str
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
	>使用copy进行字符串到byte数组转换
	```	
    pHashStr := "Genesis Block"
	var pHash [32]byte
	copy(pHash[:], []byte(pHashStr))
	```

4. 序列化实践：复杂对象应该分别实现各种子结构的MarshalJSON

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
5. 序列化实践2：decoder.Decode()和json.Unmarshal()

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
6. 序列化实践3：
	>哈希值属于16进制编码
	```
	fmt.Sprintf("%x", b.previousHash)
	```
	```
	ph, _ := hex.DecodeString(*v.PreviousHash)
	copy(b.previousHash[:], ph[:32])
	```

7. 定时操作: 
	>过一定秒数，再启动自身，另外在bc.Mining()中有互斥锁来确保在挖矿时
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
8. OOP实践
	> - 建立一个结构体，每个属性都是私有属性，然后写出GetFunc
	> - 实现一个NewFunc，用来返回这个结构的指针，NewFunc不属于该结构体
	> - 实体类应该写出Print() func

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
	> - 序列化操作参见上面
	> - 该结构体如果包含读写操作，考虑在属性中包含锁，sync.Mutex
	> - 复杂结构都用指针数组，不用实体


9. Web实践
	>golang webserver启动: 设置API - 开启监听 
	```
	func (ws *WalletServer) Run() {
		http.HandleFunc("/", ws.Index)
		http.HandleFunc("/wallet", ws.Wallet)
		http.HandleFunc("/wallet/amount", ws.WalletAmount)
		http.HandleFunc("/transaction", ws.CreateTransaction)
		log.Fatal(http.ListenAndServe("0.0.0.0:"+strconv.Itoa(int(ws.Port())), nil))
	}
	```
	>收到请求：取得Method， 使用template.ParseFiles返回index.html
	```
	func (ws *WalletServer) Index(w http.ResponseWriter, req *http.Request) {
			switch req.Method {
			case http.MethodGet:
				t, _ := template.ParseFiles(path.Join(tempDir, "index.html"))
				t.Execute(w, "")
			default:
				log.Printf("ERROR: Invalid HTTP Method")
		}
	}
	```
	>index.html：接受点击事件，发起ajax请求,用JSON.stringify来序列化请求内容，并等待内容返回
	```
		$('#send_money_button').click(function () {
		let confirm_text = 'Are you sure to send?';
		let confirm_result = confirm(confirm_text);
		if (confirm_result !== true) {
			alert('Canceled');
			return
		}
		let transaction_data = {
			'sender_private_key': $('#private_key').val(),
			'sender_blockchain_address': $('#blockchain_address').val(),
			'recipient_blockchain_address': $('#recipient_blockchain_address').val(),
			'sender_public_key': $('#public_key').val(),
			'value': $('#send_amount').val(),
		};
		$.ajax({
			url: '/transaction',
			type: 'POST',
			contentType: 'application/json',
			data: JSON.stringify(transaction_data),
			success: function (response) {
				console.info(response);
				if (response.message == 'fail') {
					alert('Send fail')
				} else {
					alert('Send success');
				}
			},
			error: function (response) {
				console.error(response);
				alert('Send failed');
			}
		})
	});
	```
	>收到请求：取得Method， 使用json.NewDecoder来反序列化
	```
	case http.MethodPost:
	decoder := json.NewDecoder(req.Body)
	var t wallet.TransactionRequest
	err := decoder.Decode(&t)
	```
	>验证后拼接发送到链里的结构体，用默认json.Marshal序列化后，发送post请求给blockchainserver，
	等到返回结果再用w.Header().add()和io.WriteString返给钱包
	```
	bt := &block.TransactionRequest{
		SenderBlockchainAddress:    t.SenderBlockchainAddress,
		RecipientBlockchainAddress: t.RecipientBlockchainAddress,
		SenderPublicKey:            t.SenderPublicKey,
		Value:                      &value32,
		Signature:                  &signatureStr,
	}
	m, _ := json.Marshal(bt)
	buf := bytes.NewBuffer(m)

	w.Header().Add("Content-Type", "application/json")
	resp, _ := http.Post(ws.Gateway()+"/transactions", "application/json", buf)
	if resp.StatusCode == 201 {
		io.WriteString(w, string(utils.JsonStatus("success")))
		return
	}
	io.WriteString(w, string(utils.JsonStatus("fail")))
	```
	>带参数request,req.URL.Query().Get()，及另一种发送Get请求给blockchainserver,用Add()拼接参数
	```
	blockchainAddress := req.URL.Query().Get("blockchain_address")
	endpoint := fmt.Sprintf("%s/amount", ws.Gateway())
	client := &http.Client{}
	bcsReq, _ := http.NewRequest("GET", endpoint, nil)
	q := bcsReq.URL.Query()
	q.Add("blockchain_address", blockchainAddress)
	bcsReq.URL.RawQuery = q.Encode()
	bcsResp, err := client.Do(bcsReq)
	```
	>确认Node可用性 DialTimeout
	```
	func IsFoundHost(host string, port uint16) bool {
		target := fmt.Sprintf("%s:%d", host, port)
		_, err := net.DialTimeout("tcp", target, 1*time.Second)
		if err != nil {
			fmt.Printf("%s %v\n", target, err)
			return false
		}
		return true
	}
	```
10. 正则表达式：
	```
	var PATTERN = regexp.MustCompile(`((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3})(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)`)
	m := PATTERN.FindStringSubmatch(myHost)
	```
11. 通过OS包发现host
	```
	func GetHost() string {
		hostname, err := os.Hostname()
		if err != nil {
			return "127.0.0.1"
		}
		address, err := net.LookupHost(hostname)
		if err != nil {
			return "127.0.0.1"
		}
		return address[0]
	}
	```
### Test
### TODO
### Refs
