import tensorflow._api.v2.compat.v1 as tf

#The original saved TensorFlow model was saved in TensorFlow 1 - We must disable v2 behaviour to ensure compatibility
tf.disable_v2_behavior()
tf.compat.v1.disable_eager_execution()

#Load the saved graph definition
with tf.gfile.GFile('models/graph/mobilenet_v2_large/graph_opt.pb', 'rb') as f:
    graph_def = tf.GraphDef()
    graph_def.ParseFromString(f.read())

# Get the default tensor flow graph. This will be where we build our model
graph = tf.get_default_graph()

#A 1D array of rgb-color 32-bit integers (arranged row by row) are converted to a tensor of floats of shape [1,h,w,3] -
#One float value for each colour channel

#These will be the inputs to the new model.
tensor_input = tf.placeholder(tf.int32, shape=(None), name="input_image")
tensor_input_width = tf.placeholder(tf.int32, shape=(), name="input_width")
tensor_input_height = tf.placeholder(tf.int32, shape=(), name="input_height")
tensor_input_mirror = tf.placeholder(tf.bool, shape=(), name = "input_mirror")

rdC = tf.cast(tf.bitwise.bitwise_and(tf.bitwise.right_shift(tensor_input, 16), 255), tf.float32)
grC = tf.cast(tf.bitwise.bitwise_and(tf.bitwise.right_shift(tensor_input, 8), 255), tf.float32)
blC = tf.cast(tf.bitwise.bitwise_and(tensor_input, 255), tf.float32)
tensor_inputcast = tf.expand_dims(tf.reshape(tf.stack([rdC, grC, blC], axis=1), shape=[tensor_input_height,tensor_input_width,3]),axis=0)

tensor_inputcast2 = tf.cond(tensor_input_mirror,
                            true_fn=lambda: tf.image.flip_left_right(tensor_inputcast),
                            false_fn=lambda: tf.identity(tensor_inputcast))

#Now join the imported model onto our tensors
tf.import_graph_def(graph_def, name='PoseEstimator', input_map={'image:0':tensor_inputcast2})

#Get the output tensor from the existing model
tensor_output = graph.get_tensor_by_name('PoseEstimator/Openpose/concat_stage7:0')

print("tensor_output.shape: ", tensor_output.shape)

#These are all the confidence heatmaps we need
tensor_heatmaps = tensor_output[0, :, :, :18]

#Needed so that the Java library can find this tensor by name from the exported model.
tensor_heatmaps = tf.identity(tensor_heatmaps,"heatmaps")
print(tensor_heatmaps)

#Find the maximum value across both axis for all 18 heatmaps
tensor_shape = tf.shape(tensor_heatmaps[ : , : , 0])
tensor_rows = tensor_shape[0]
tensor_cols = tensor_shape[1]
tensor_flatten = tf.reshape(tensor_heatmaps[ : , : , :18], [tensor_rows*tensor_cols, 18])
tensor_argmax = tf.math.argmax(tensor_flatten, axis=0, output_type = tf.dtypes.int32)
tensor_y = tf.math.floordiv(tensor_argmax, tensor_cols, name="y_out")
tensor_x = tf.math.floormod(tensor_argmax, tensor_cols, name="x_out")

#Save the model, this creates the file that will be loaded by the Java Processing library
persistent_sess = tf.Session(graph=graph, config=None)

tf.saved_model.simple_save(
     persistent_sess,
     export_dir="Model",
     inputs = {'image': tensor_input, 'image_width': tensor_input_width, 'image_height': tensor_input_height},
     outputs= {'x_out': tensor_x, 'y_out': tensor_y, 'heatmaps': tensor_heatmaps} #'max_val': tensor_val
)

persistent_sess.close()