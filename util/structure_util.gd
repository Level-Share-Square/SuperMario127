class_name structure_util

class ListNode:
	var value = null
	var next: ListNode = null
	var prev: ListNode = null
	
	func _init(val): value = val
	
class Queue:
	var head: ListNode = null
	var tail: ListNode = null
	var size: int = 0
	
	func append(val: Vector2):
		var new_node := ListNode.new(val)
		if not head: 
			head = new_node
			tail = new_node
		else:
			tail.next = new_node
			new_node.prev = tail
			tail = new_node
		size += 1
		
	func pop_front():
		if not head: return null
		
		var old_head = head
		head = head.next
		if head:
			head.prev = null
		else:
			tail = null
		size -= 1
		return old_head.value
		
	func is_empty(): return size == 0
