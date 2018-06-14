#!/usr/bin/env python

import rospy #importar ros para python
from sensor_msgs.msg import Image
import cv2
from cv_bridge import CvBridge
from std_msgs.msg import String, Int32 # importar mensajes de ROS tipo String y tipo Int32
from geometry_msgs.msg import Twist # importar mensajes de ROS tipo geometry / Twist


class Template(object):
	def __init__(self, args):
		super(Template, self).__init__()
		self.args = args
		self.subscriber = rospy.Subscriber("/duckiebot/camera_node/image_raw",Image,self.callback)
		self.bridge = CvBridge()

	def callback(self,msg):
		image = self.bridge.imgmsg_to_cv2(msg,"bgr8")
		filename = str(rospy.get_time()) + ".jpg"
		cv.SaveImage("~/patos/"+filename, image)
		rospy.sleep( 2 )
		
	#def publicar(self):

	#def callback(self,msg):


def main():
	rospy.init_node('test') #creacion y registro del nodo!

	obj = Template('args') # Crea un objeto del tipo Template, cuya definicion se encuentra arriba

	#objeto.publicar() #llama al metodo publicar del objeto obj de tipo Template

	rospy.spin() #funcion de ROS que evita que el programa termine -  se debe usar en  Subscribers


if __name__ =='__main__':
	main()
