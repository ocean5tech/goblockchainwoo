package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestBlockNew(t *testing.T) {
	nonce := 1
	prevHash := "test"
	newb := NewBlock(nonce, prevHash)
	assert.Equal(t, newb.nonce, nonce)
	assert.Equal(t, newb.previousHash, prevHash)
}
