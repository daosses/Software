#!/usr/bin/env python

import rospy #importar ros para python
from std_msgs.msg import String, Int32 # importar mensajes de ROS tipo String y tipo Int32
from geometry_msgs.msg import Twist # importar mensajes de ROS tipo geometry / Twist
from sensor_msgs.msg import Joy
from duckietown_msgs.msg import Twist2DStamped
 
class Control(object):
	def __init__(self, args):
		super(Control, self).__init__()
		self.args = args
		self.publisher = rospy.Publisher("/duckiebot/wheels_driver_node/car_cmd", Twist2DStamped, queue_size = 0)
		self.subscriber = rospy.Subscriber("/duckiebot/joy", Joy,self.callback)
		self.twist = Twist2DStamped()

	#def publicar(self):

	#def callback(self,msg):
	def callback(self,msg):
		angular = msg.axes[0]*6
		velocidad = msg.axes[1]*0.4
		self.twist.v = velocidad
		self.twist.omega = angular
		if(msg.buttons[1] == 1): #B frena
			self.twist.v = 0
			self.twist.omega = 0
			self.publisher.publish(self.twist)
		else:
			if(msg.buttons[0] == 1): 
				self.publisher.publish(self.twist)
		



def main():
	rospy.init_node('control') #creacion y registro del nodo!

	obj = Control('args') # Crea un objeto del tipo Template, cuya definicion se encuentra arriba
	

	#objeto.publicar() #llama al metodo publicar del objeto obj de tipo Template
	

	#rospy.spin() #funcion de ROS que evita que el programa termine -  se debe usar en  Subscribers
	rospy.spin()


if __name__ =='__main__':
	main()
