package poseestimator;

import org.tensorflow.*;
import org.tensorflow.ndarray.FloatNdArray;
import org.tensorflow.ndarray.IntNdArray;
import org.tensorflow.types.TBool;
import org.tensorflow.types.TFloat32;
import org.tensorflow.types.TInt32;

import java.io.File;
import java.net.URISyntaxException;
import java.util.List;

import processing.core.*;

import static java.lang.System.currentTimeMillis;

public class PoseEstimator
{
    private final static int VERSION = 6; //Updated when changes to the code are made to keep track of alterations.

    public static void main(String[] params){}

    private PApplet parent;

    private boolean ready = false;
    private boolean dataAvailable = false;
    private boolean starting = false;

    //TensorFlow objects
    private Session sess;
    private SavedModelBundle savedModelBundle;
    private Graph graph;

    //Stores the pose data once it has been estimated
    private IntNdArray poseDataX;
    private IntNdArray poseDataY;
    private FloatNdArray poseHeatmaps;

    private int heatMapWidth, heatMapHeight;

    private String modelPath;

    public PoseEstimator(PApplet parent)
    {
        System.out.println("POSE ESTIMATOR V" + VERSION);

        this.parent = parent;
        parent.registerMethod("dispose", this);
        //Get the directory outside the jar file where the model is stored
        String s;
        try
        {
            s = getClass()
                    .getProtectionDomain()
                    .getCodeSource()
                    .getLocation()
                    .toURI()
                    .getPath();
        }
        catch(URISyntaxException x)
        {
            System.out.println(x);
            return;
        }

        modelPath = new File(s).toPath().getParent().getParent().toString() + "\\Model";
    }

    public void start()
    {
        starting = true;
        Runnable modelLoadThread = () ->
        {
            long time = currentTimeMillis();
            System.out.println("Loading model...");
            savedModelBundle = SavedModelBundle.load(modelPath, "serve");
            System.out.println("Getting bundle...");
            graph = savedModelBundle.graph();
            System.out.println("Starting session...");
            sess = new Session(graph);

            System.out.println("Running warm-up...");

            //Do a dry run to warm up.
            sess.runner()
                    .feed("input_image", TInt32.vectorOf(new int[32*32]))
                    .feed("input_width", TInt32.scalarOf(32))
                    .feed("input_height", TInt32.scalarOf(32))
                    .feed("input_mirror", TBool.scalarOf(false))
                    .fetch("x_out")
                    .fetch("y_out")
                    .fetch("heatmaps")
                    .run();

            time = currentTimeMillis() - time;
            ready=true;
            starting = false;
            System.out.println("Done... Took " + (time/1000.0) + " seconds.");

        };
        new Thread(modelLoadThread).start();
    }

    public void estimate(PImage pg, boolean mirrored)
    {
        if (!ready) return;
        pg.loadPixels();
        Tensor<TInt32> image = TInt32.vectorOf(pg.pixels);
        Tensor<TInt32> image_width = TInt32.scalarOf(pg.width);
        Tensor<TInt32> image_height = TInt32.scalarOf(pg.height);
        Tensor<TBool> image_mirror = TBool.scalarOf(mirrored);
        heatMapWidth = pg.width >> 3; //Heat map dimensions are 8 times as small as the original image
        heatMapHeight = pg.height >> 3;

        List<Tensor<?>> results = sess.runner()
                .feed("input_image", image)
                .feed("input_width", image_width)
                .feed("input_height", image_height)
                .feed("input_mirror", image_mirror)
                .fetch("x_out") //!!!!!!
                .fetch("y_out")
                //.fetch("max_val")
                .fetch("heatmaps")
                .run();

        poseDataX = results.get(0).expect(TInt32.DTYPE).data().get();
        poseDataY = results.get(1).expect(TInt32.DTYPE).data().get();
        //poseVal = results.get(2).expect(TFloat32.DTYPE).data().get();

        Tensor<TFloat32> vvv = results.get(2).expect(TFloat32.DTYPE);
        poseHeatmaps = vvv.data().get();

        for(Tensor<?> t: results) { t.close(); }
        dataAvailable = true;
    }

    public void estimate(PImage pg)
    {
        estimate(pg, false);
    }

    public boolean isStarting() { return starting; }
    public boolean isReady() { return ready; }
    public boolean isDataAvailable() { return dataAvailable; }

    public int getPoseDataX(int keypoint)
    {
        //Implementation of the algorithm for getting pixel-wise approximations of the keypoint locations from the
        //heatmap. See iteration 1 in the report for details.

        int nx = poseDataX.getInt(keypoint);
        int ny = poseDataY.getInt(keypoint);
        if (nx < 1 || nx >= heatMapWidth - 1 || ny < 1 || ny >= heatMapHeight - 1) return -1;

        float v = poseHeatmaps.getFloat(ny, nx, keypoint); //poseVal.getFloat(keypoint);//
        float vxn = poseHeatmaps.getFloat(ny, nx + 1, keypoint);
        float vxp = poseHeatmaps.getFloat(ny, nx - 1, keypoint);
        float vx;
        if (vxn >= vxp)
        {
            vx = 1 - ((v - vxn) / (2 * (v - vxp)));
        } else
        {
            vx = (v - vxp) / (2 * (v - vxn));
        }
        return (int) ((nx + vx) * 8);
    }

    public int getPoseDataY(int keypoint)
    {
        int nx = poseDataX.getInt(keypoint);
        int ny = poseDataY.getInt(keypoint);
        if (nx < 1 || nx >= heatMapWidth - 1 || ny < 1 || ny >= heatMapHeight - 1) return -1;

        float v = poseHeatmaps.getFloat(ny, nx, keypoint);//poseVal.getFloat(keypoint);//poseHeatmaps.getFloat(ny, nx, keypoint);
        float vyn = poseHeatmaps.getFloat(ny+1, nx, keypoint);
        float vyp = poseHeatmaps.getFloat(ny-1, nx, keypoint);
        float vy;
        if (vyn >= vyp)
        {
            vy = 1 - ((v - vyn) / (2*(v - vyp)));
        }
        else
        {
            vy = (v - vyp) / (2*(v - vyn));
        }
        return (int) ((ny + vy) * 8);
    }

    public float getConfidence(int keypoint)
    {
        int nx = poseDataX.getInt(keypoint);
        int ny = poseDataY.getInt(keypoint);
        return poseHeatmaps.getFloat(ny, nx, keypoint);
    }

    public float getHeatmap(int keypoint, int x, int y)
    {
        return poseHeatmaps.getFloat(y, x, keypoint);
    }

    //Automatically called by Processing to shut the library.
    public void dispose()
    {
        if (ready)
        {
            sess.close();
            graph.close();
            savedModelBundle.close();
        }
        dataAvailable = false;
        ready = false;
    }
}

