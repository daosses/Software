#!/usr/bin/env python

import rospy #importar ros para python
from sensor_msgs.msg import Image 
from geometry_msgs.msg import Point
import cv2
from cv_bridge import CvBridge
import numpy as np

class Test1(object):
	def __init__(self, args):
		super(Test1, self).__init__()
		self.args = args
		self.publisher = rospy.Publisher( "/chat",Image, queue_size=1)
		self.publisher2 = rospy.Publisher( "/coordenadas", Point , queue_size=10)
		self.subscriber = rospy.Subscriber("/duckiebot/camera_node/image/raw",Image,self.callback)
		self.bridge = CvBridge()		



	#def publicar(self):	
	#def publicar(self):
			
		
	def callback(self,msg):
		lower_yellow= np.array(([10,140,140]))
		upper_yellow= np.array(([60,255,255]))
		image = self.bridge.imgmsg_to_cv2(msg,"bgr8")
		image_out = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
		mask = cv2.inRange(image_out,lower_yellow,upper_yellow)
		image_out = cv2.bitwise_and(image_out,image_out,mask=mask)
		kernel = np.ones((5,5),np.uint8) # Matriz de 1s de 5x5 ocupada en las transfo
		image_out = cv2.erode(image_out, kernel, iterations = 1)
		image_out = cv2.dilate(image_out, kernel, iterations = 2)
		_, contours, hierarchy = cv2.findContours(mask, cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
		fx = 171.19787023635135
		fy = 169.195912562154
		hr = 3
		cx = 162.3096515078546
		cy = 124.51460608723367
		coordenadas = Point()
		for i in contours:
			x,y,w,h = cv2.boundingRect(i)
			if w*h>=300:
				cv2.rectangle(image, (x,y), (x+w,y+h), (0,255,0), 2) 

				zr = fx*hr/h

				u = x + w/2
 				v = y + h/2

				xr = (u-cx)*zr/fx
				yr = (v-cy)*zr/fy 

				coordenadas.x = xr
				coordenadas.y = yr
				coordenadas.z = zr
				self.publisher2.publish(coordenadas)	

		final = self.bridge.cv2_to_imgmsg(image, "bgr8")
		self.publisher.publish(final)

		#x,y,w,h = cv2.boundingRect(cnt)
		#cv2.rectangle(img, (x1,y1), (x2,y2), (0,0,0), 2)

		

#msg = String()
#msg.data = "hola"
def main():
	rospy.init_node('test') #creacion y registro del nodo!

	obj = Test1('args') # Crea un objeto del tipo Template, cuya definicion se encuentra arriba

	#objeto.publicar() #llama al metodo publicar del objeto obj de tipo Template

	rospy.spin() #funcion de ROS que evita que el programa termine -  se debe usar en  Subscribers


if __name__ =='__main__':
	main()
