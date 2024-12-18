package main

import (
	bridge "core/dart-bridge"
	"encoding/json"
	"github.com/metacubex/mihomo/constant"
)

type MessageType string

type Delay struct {
	Name  string `json:"name"`
	Value int32  `json:"value"`
}

type Process struct {
	Id       int64              `json:"id"`
	Metadata *constant.Metadata `json:"metadata"`
}

var (
	Port        int64 = -1
	ServicePort int64 = -1
)

const (
	LogMessage     MessageType = "log"
	ProtectMessage MessageType = "protect"
	DelayMessage   MessageType = "delay"
	ProcessMessage MessageType = "process"
	RequestMessage MessageType = "request"
	StartedMessage MessageType = "started"
	LoadedMessage  MessageType = "loaded"
)

type Message struct {
	Type MessageType `json:"type"`
	Data interface{} `json:"data"`
}

func (message *Message) Json() (string, error) {
	data, err := json.Marshal(message)
	return string(data), err
}

func SendMessage(message Message) {
	s, err := message.Json()
	if err != nil {
		return
	}
	if Port == -1 && ServicePort == -1 {
		Action{
			Method: messageMethod,
		}.callback(s)
		return
	}
	if handler, ok := messageHandlers[message.Type]; ok {
		handler(s)
	} else {
		sendToPort(s)
	}
}

var messageHandlers = map[MessageType]func(string) bool{
	ProtectMessage: sendToServicePort,
	ProcessMessage: sendToServicePort,
	StartedMessage: conditionalSend,
	LoadedMessage:  conditionalSend,
}

func sendToPort(s string) bool {
	return bridge.SendToPort(Port, s)
}

func sendToServicePort(s string) bool {
	return bridge.SendToPort(ServicePort, s)
}

func conditionalSend(s string) bool {
	isSuccess := sendToPort(s)
	if !isSuccess {
		return sendToServicePort(s)
	}
	return isSuccess
}
