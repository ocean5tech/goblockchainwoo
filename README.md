# goblockchainwoo

1. 使用copy进行字符串到byte数组转换

```	
    pHashStr := "Genesis Block"
	var pHash [32]byte
	copy(pHash[:], []byte(pHashStr))
```