import traceback
import os
import subprocess

import tensorflow as tf


# Checks whether dependency is met.
is_supported = False
try:
  _lite_v1 = tf.compat.v1.lite
  _get_potentially_supported_ops = _lite_v1.experimental.get_potentially_supported_ops
  _TFLiteConverter = _lite_v1.TFLiteConverter
  _gfile = tf.io.gfile.walk
  is_supported = True
except AttributeError:
  pass


ISSUE_LINK = "https://github.com/tensorflow/tensorflow/issues/new?template=40-tflite-op-request.md"
SELECT_TF_OPS_LINK = "https://www.tensorflow.org/lite/using_select_tf_ops"


def _get_suggestion(error):
  """Gets suggestion by identifying error message."""
  error_str = str(error)
  suggestion_map = {
      "both shapes must be equal":
          "Please input your input_shapes",
      ISSUE_LINK:
          "Please report the error log to {}, or try select TensorFlow ops: {}."
          .format(ISSUE_LINK, SELECT_TF_OPS_LINK),
      "a Tensor which does not exist": 
          "please check your input_arrays and output_arrays argument."
  }
  for k in suggestion_map:
    if k in error_str:
      return suggestion_map[k]
  return ""


class ConvertError(Exception):
  """Error occurs in TF Lite conversion."""

  def __init__(self, from_exception, suggestion=None):
    super(ConvertError, self).__init__(str(from_exception))
    self.error = from_exception
    self.type = type(from_exception).__name__
    self.suggestion = suggestion
    self.stack_trace = traceback.format_exc()


def get_exception_info(e):
  """Gets formated exception infor."""
  if not isinstance(e, ConvertError):
    e = ConvertError(e)
  return {'type': e.type,
          'error': e.error,
          'suggestion': e.suggestion,
          'stack_trace': e.stack_trace}


def script_from_saved_model(saved_model_dir, output_file, input_arrays,
                            output_arrays):
  """Generates a script for saved model to convert from TF to TF Lite."""
  return r"""# --- Python code ---
import tensorflow as tf
lite = tf.compat.v1.lite

saved_model_dir = '{saved_model_dir}'
output_file = '{output_file}'
converter = lite.TFLiteConverter.from_saved_model(
    saved_model_dir,
    input_arrays={input_arrays},
    output_arrays={output_arrays})
tflite_model = converter.convert()
with tf.io.gfile.GFile(output_file, 'wb') as f:
  f.write(tflite_model)
  print('Write file: %s' % output_file)
""".format(
    saved_model_dir=saved_model_dir,
    output_file=output_file,
    input_arrays=input_arrays,
    output_arrays=output_arrays)


def execute(script, verbose=False):
  """Executes script from subprocess, and returns tuple(success, stdout, stderr)."""
  cmds = ['python', '-c', script]
  if verbose:
    print('Execute: %s' % cmds)
  pipe = subprocess.Popen(cmds,
                          stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE)
  stdout, stderr = pipe.communicate()
  success = (pipe.returncode == 0)
  return success, stdout, stderr


def get_potentially_supported_ops():
  """Gets potentially supported ops.

  Returns:
    list of str for op names.
  """
  supported_ops = _get_potentially_supported_ops()
  op_names = [s.op for s in supported_ops]
  return op_names


def get_saved_model_dirs(logdir):
  """Gets a list of nested saved model dirs."""
  maybe_contains_dirs = []
  for dirname, subdirs, files in tf.io.gfile.walk(logdir):
    relpath = os.path.relpath(dirname, logdir)
    for d in subdirs:
      subdir = os.path.normpath(os.path.join(relpath, d))
      if tf.saved_model.contains_saved_model(os.path.join(logdir, subdir)):
        maybe_contains_dirs.append(subdir)
  return maybe_contains_dirs


def safe_makedirs(dirpath):
  """Ensures dir is made, and safely handles errors."""
  try:
    if not tf.io.gfile.exists(dirpath):
      tf.io.gfile.makedirs(dirpath)
      return True
  except:
    pass
  return False
