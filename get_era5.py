import cdsapi
import os
import time


SFC_VARS = ['10m_u_component_of_wind', '10m_v_component_of_wind', '2m_dewpoint_temperature',
            '2m_temperature', 'land_sea_mask', 'mean_sea_level_pressure',
            'sea_ice_cover', 'sea_surface_temperature', 'skin_temperature',
            'snow_depth', 'soil_temperature_level_1', 'soil_temperature_level_2',
            'soil_temperature_level_3', 'soil_temperature_level_4', 'surface_pressure',
            'volumetric_soil_water_layer_1', 'volumetric_soil_water_layer_2', 'volumetric_soil_water_layer_3',
            'volumetric_soil_water_layer_4']

PL_VARS = ['geopotential', 'relative_humidity',  #  'specific_humidity',
           'temperature', 'u_component_of_wind', 'v_component_of_wind']

# TODO: only for leap year
mon_days = {
    "01": 31, "02": 29, "03": 31, "04": 30, "05": 31, "06": 30,
    "07": 31, "08": 31, "09": 30, "10": 31, "11": 30, "12": 31,
}


def era5_download(dates_dict, data_type, base_savedir):
    """
    :param dates_dict:
    :param data_type: <str>: pl, sfc
    :param base_savedir:
    :return:
    """
    base_request = {'product_type': 'reanalysis',
                    'format': 'grib'}

    c = cdsapi.Client()
    
    for key in dates_dict:
        if type(dates_dict[key]) is not list:
            dates_dict[key] = [dates_dict[key], ]

    for year in dates_dict["year"]:
        for month in dates_dict["month"]:
            for day in dates_dict["day"]:
                if int(day) > mon_days[month]:
                    continue

                for hour in dates_dict["time"]:

                    save_dir = os.path.join(base_savedir, "%s%s" % (year, month))
                    if not os.path.exists(save_dir):
                        os.makedirs(save_dir)
                    save_prefix = "%s%s%s%s" % (year, month, day, hour[:2])
                    base_request.update({'year': year,
                                         'month': month,
                                         'day': day,
                                         'time': [
                                             hour,
                                         ]})

                    if data_type == "sfc":
                        base_request.update({
                            'variable': SFC_VARS,
                        })
                        c.retrieve('reanalysis-era5-single-levels',
                                   base_request,
                                   os.path.join(save_dir, '%s_sfc.grib' % save_prefix))
                    elif data_type == "pl":
                        base_request.update({
                            'variable': PL_VARS,
                            'pressure_level': [
                                '1','2','3',
                                '5','7','10',
                                '20','30','50',
                                '70','100','125',
                                '150','175','200',
                                '225','250','300',
                                '350','400','450',
                                '500','550','600',
                                '650','700','750',
                                '775','800','825',
                                '850','875','900',
                                '925','950','975',
                                '1000'
                            ],
                        })
                        c.retrieve('reanalysis-era5-pressure-levels',
                                   base_request,
                                   os.path.join(save_dir, '%s_pl.grib' % save_prefix))
                    time.sleep(50)


if __name__ == "__main__":
    req_dates = {
        'year': '2016',
        'month': #['01','02','03',
                #'04',
                '05',#'06',
                #'07','08','09',
                #'10','11','12',],
        'day': [#'01','02',
                #'03',
                #'04','05','06',
                #'07','08','09',
                #'10','11','12',
                #'13','14','15',
                #'16','17','18',
                #'19','20','21',
                #'22','23','24',
                #'25','26',
                '27',
                '28','29','30',
                '31'],
        'time': [
            '00:00', '03:00', 
            '06:00', '09:00', '12:00', 
            '15:00', '18:00', '21:00',
        ],
    }
    era5_download(req_dates, "pl", "/data/ERA5/")

